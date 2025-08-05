<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
$host = '127.0.0.1';
$dbname = 'product_app_db';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit();
}

// Get the request method and path
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', trim($path, '/'));

// Route handling
if (in_array('products', $pathParts)) {
    $productIndex = array_search('products', $pathParts);
    $productId = isset($pathParts[$productIndex + 1]) ? $pathParts[$productIndex + 1] : null;
    
    switch ($method) {
        case 'GET':
            if ($productId) {
                getProduct($pdo, $productId);
            } else {
                getProducts($pdo);
            }
            break;
        case 'POST':
            createProduct($pdo);
            break;
        case 'PUT':
            if ($productId) {
                updateProduct($pdo, $productId);
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'Product ID required for update']);
            }
            break;
        case 'DELETE':
            if ($productId) {
                deleteProduct($pdo, $productId);
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'Product ID required for delete']);
            }
            break;
        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
    }
} elseif (in_array('categories', $pathParts)) {
    if ($method === 'GET') {
        getCategories($pdo);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint not found']);
}

// Get all products
function getProducts($pdo) {
    try {
        $stmt = $pdo->query("SELECT * FROM products ORDER BY created_at DESC");
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Convert to expected format
        $formattedProducts = array_map(function($product) {
            return [
                'id' => $product['id'],
                'name' => $product['name'],
                'category' => $product['category'],
                'price' => (float)$product['price'],
                'description' => $product['description'] ?? '',
                'stock_quantity' => (int)$product['stock_quantity'],
                'image' => $product['image'] ?? '',
                'created_at' => $product['created_at'],
                'updated_at' => $product['updated_at']
            ];
        }, $products);
        
        echo json_encode($formattedProducts);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch products: ' . $e->getMessage()]);
    }
}

// Get single product
function getProduct($pdo, $id) {
    try {
        $stmt = $pdo->prepare("SELECT * FROM products WHERE id = ?");
        $stmt->execute([$id]);
        $product = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($product) {
            $formattedProduct = [
                'id' => $product['id'],
                'name' => $product['name'],
                'category' => $product['category'],
                'price' => (float)$product['price'],
                'description' => $product['description'] ?? '',
                'stock_quantity' => (int)$product['stock_quantity'],
                'image' => $product['image'] ?? '',
                'created_at' => $product['created_at'],
                'updated_at' => $product['updated_at']
            ];
            echo json_encode($formattedProduct);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Product not found']);
        }
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch product: ' . $e->getMessage()]);
    }
}

// Create new product
function createProduct($pdo) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        // Handle both JSON and form data
        if (!$input) {
            $input = $_POST;
        }
        
        $name = $input['name'] ?? '';
        $category = $input['category'] ?? '';
        $price = $input['price'] ?? 0;
        $description = $input['description'] ?? '';
        $stock_quantity = $input['stock_quantity'] ?? 0;
        $image = $input['image'] ?? $input['image_base64'] ?? '';
        
        if (empty($name) || empty($category) || $price <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields: name, category, price']);
            return;
        }
        
        $stmt = $pdo->prepare("INSERT INTO products (name, category, price, description, stock_quantity, image, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())");
        $stmt->execute([$name, $category, $price, $description, $stock_quantity, $image]);
        
        $productId = $pdo->lastInsertId();
        
        // Return the created product
        getProduct($pdo, $productId);
        
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to create product: ' . $e->getMessage()]);
    }
}

// Update product
function updateProduct($pdo, $id) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        // Handle both JSON and form data
        if (!$input) {
            $input = $_POST;
        }
        
        // For PUT requests with multipart data, parse manually
        if (empty($input) && $_SERVER['REQUEST_METHOD'] === 'PUT') {
            $input = parseMultipartData();
        }
        
        $fields = [];
        $values = [];
        
        if (isset($input['name'])) {
            $fields[] = 'name = ?';
            $values[] = $input['name'];
        }
        if (isset($input['category'])) {
            $fields[] = 'category = ?';
            $values[] = $input['category'];
        }
        if (isset($input['price'])) {
            $fields[] = 'price = ?';
            $values[] = $input['price'];
        }
        if (isset($input['description'])) {
            $fields[] = 'description = ?';
            $values[] = $input['description'];
        }
        if (isset($input['stock_quantity'])) {
            $fields[] = 'stock_quantity = ?';
            $values[] = $input['stock_quantity'];
        }
        if (isset($input['image']) || isset($input['image_base64'])) {
            $fields[] = 'image = ?';
            $values[] = $input['image'] ?? $input['image_base64'];
        }
        
        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(['error' => 'No fields to update']);
            return;
        }
        
        $fields[] = 'updated_at = NOW()';
        $values[] = $id;
        
        $sql = "UPDATE products SET " . implode(', ', $fields) . " WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($values);
        
        if ($stmt->rowCount() > 0) {
            getProduct($pdo, $id);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Product not found or no changes made']);
        }
        
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to update product: ' . $e->getMessage()]);
    }
}

// Delete product
function deleteProduct($pdo, $id) {
    try {
        $stmt = $pdo->prepare("DELETE FROM products WHERE id = ?");
        $stmt->execute([$id]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode(['message' => 'Product deleted successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Product not found']);
        }
        
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to delete product: ' . $e->getMessage()]);
    }
}

// Get categories
function getCategories($pdo) {
    try {
        $stmt = $pdo->query("SELECT DISTINCT category FROM products WHERE category != '' ORDER BY category");
        $categories = $stmt->fetchAll(PDO::FETCH_COLUMN);
        echo json_encode($categories);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch categories: ' . $e->getMessage()]);
    }
}

// Parse multipart form data for PUT requests
function parseMultipartData() {
    $boundary = substr($_SERVER['CONTENT_TYPE'], strpos($_SERVER['CONTENT_TYPE'], "boundary=") + 9);
    $boundary = '--' . $boundary;
    
    $input = file_get_contents('php://input');
    $parts = explode($boundary, $input);
    $data = [];
    
    foreach ($parts as $part) {
        if (strpos($part, 'Content-Disposition: form-data;') !== false) {
            // Extract field name
            preg_match('/name="([^"]*)"/', $part, $matches);
            if (isset($matches[1])) {
                $name = $matches[1];
                // Extract value (everything after the double newline)
                $value = trim(substr($part, strpos($part, "\r\n\r\n") + 4));
                $data[$name] = $value;
            }
        }
    }
    
    return $data;
}
?>
