
<?php

ini_set('display_errors', 'On');
header('Content-Type: application/json');
error_reporting(E_ALL);
include("functions.php");

if($_SERVER["REQUEST_METHOD"] == "POST")
{
    switch ($_GET['action']) {
		
        case "login":
            $post = json_decode(file_get_contents("php://input"), true);
            $user = $post["user"];
            $pass = $post["pass"];
			
            login($user, $pass);
        break;
		
        case "signup":
			$post = json_decode(file_get_contents("php://input"), true);
            $user = $post["user"];
            $pass1 = $post["pass1"];
            $pass2 = $post["pass2"];
			
            signup($user, $pass1, $pass2);
		break;
		
		case "post":
			$post = json_decode(file_get_contents("php://input"), true);
            $userId = $post["userId"];
            $image = $post["image"];
			
			createPost($userId, $image);
			/*$target_dir = "/drawffimages"; // multi part request
			
			if(!file_exists($target_dir))
				mkdir($target_dir, 0777, true);

			$target_dir = $target_dir . "/" . basename($_FILES["file"]["name"]);

			if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_dir)) {
				echo "The file " . basename($_FILES["file"]["name"]) . " has been uploaded. User id: " . $userId;
			} else {
				echo "Error. User id: " . $userId;
			}*/
		break;
		
        case "getPosts":
            $post = json_decode(file_get_contents("php://input"), true);
            $userId = $post["userId"];
            $postDate = $post["postDate"];
            $type = $post["type"];
			$isProfile = $post["isProfile"];
            getPosts($userId, $postDate, $type, $isProfile);
		break;
		
    }
}

?>