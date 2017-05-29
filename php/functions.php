
<?php

ini_set('display_errors', 'On');
error_reporting(E_ALL);
$connect = new mysqli('localhost', 'x', 'x', 'x');
if($connect->connect_error)
	echo "success";
$connect->query("SET NAMES UTF8");

function login($user, $pass) {
	global $connect;
	if (usernameAlreadyExist($user)) {
		  $userInfo = getUserInfo($user);
		 ($userInfo['user_password'] == md5($pass)) ? $result = $userInfo['user_id'] : $result = "-1"; } // wrong password
	else {$result = "-2";} // cannot find username

	echo $result;
}

function signup($user, $password, $password2) {
	global $connect;
	$result = "";

	if (empty($user)) 
		$result = "Please enter your username"; // Please enter your username
	else if (empty($password)) 
		$result = "Please enter your password"; // Please enter your password
	else if (empty($password2)) 
		$result = "Please enter your password again"; // Please enter your password2
	else if (strlen($user) <= 4 || strlen($user) >= 20)
		$result = "Please pick a username between 4 - 20 characters"; // Please pick a username between 4 - 20 characters
	else if (!ctype_alnum($user))
		$result = "Please pick a username without special characters"; // Please pick a username without special characters
	else if (strlen($password) <= 5 || strlen($password) > 32)
		$result = "Your password must be at least 6 characters"; // Your password must be at least 6 characters
	else if (preg_match('/[\'^£$%&*()}{@#~?><>,|=_+¬-]/', $password))
		$result = "Please pick a password without special characters"; // Please pick a password without special characters
	else if ($password != $password2)
		$result = "Passwords does not match"; // Passwords does not match
	else if(usernameAlreadyExist($user))
		$result = "Username already exist"; // Username already exist
	
	if($result == "") {
		$result = "1"; // Success
		$newPassword = md5($password);
		$userId = md5(uniqid(mt_rand(), true));
		$query = $connect->query("INSERT INTO user(user_id,user_username,user_password)values('".$userId."','". $user ."','".$newPassword."');");
	}

	echo $result;
}

function createPost($userId, $image) {
    global $connect;

    $postId = md5(uniqid(mt_rand(), true));
	$imageId = md5(uniqid(mt_rand(), true));
	$date = strtotime(getDateAtTheMoment());
	
	$data = base64_decode($image);
	$source_img = imagecreatefromstring($data);
	$file = "drawffimages";
	if(!file_exists($file)) mkdir($file, 0777, true);
	$file = $file . "/" . $userId . "_" . $imageId . ".jpg";
	$imageSave = imagejpeg($source_img, $file, 100);
	
    if ($connect->query("INSERT INTO post(post_id,post_user_id,post_image_id,post_date)values('".$postId."','".$userId."','".$imageId."','".$date."');")) {
		echo "1";
	} else {
		echo "2";
	}
}

function getPosts($userId, $postDate, $type, $isProfile) {
    global $connect;

	if ($isProfile == 1) {
		if ($type == 0) {        $query = $connect->query("SELECT * FROM post WHERE post_user_id = '".$userId."' ORDER BY post_date DESC LIMIT 10"); }
		else if ($type == 1) {   $query = $connect->query("SELECT * FROM post WHERE post_date > '" . $postDate . "' AND post_user_id = '".$userId."' ORDER BY post_date ASC LIMIT 10"); }
		else if ($type == 2) {   $query = $connect->query("SELECT * FROM post WHERE post_date < '" . $postDate . "' AND post_user_id = '".$userId."' ORDER BY post_date DESC LIMIT 10"); }
	} else {
		if ($type == 0) {        $query = $connect->query("SELECT * FROM post WHERE post_user_id <> '".$userId."' ORDER BY post_date DESC LIMIT 10"); }
		else if ($type == 1) {   $query = $connect->query("SELECT * FROM post WHERE post_date > '" . $postDate . "' AND post_user_id <> '".$userId."' ORDER BY post_date ASC LIMIT 10"); }
		else if ($type == 2) {   $query = $connect->query("SELECT * FROM post WHERE post_date < '" . $postDate . "' AND post_user_id <> '".$userId."' ORDER BY post_date DESC LIMIT 10"); }
	}
	
    $posts = array();
    $lastPostDate = "0";
	
	while ($postObject = $query->fetch_object()) {
		$postObject -> username = getUsernameWithUserId($postObject -> post_user_id);
		$lastPostDate = $postObject->post_date;
		array_push($posts, $postObject);
	}
	
    $info = array("refreshDate" => strtotime(getDateAtTheMoment()),
                  "lastPostDate" => $lastPostDate);

	$result = array("info" => $info, "posts" => $posts);
    echoJsonArray($result);
}

function usernameAlreadyExist($user) {
    global $connect;
    $query = $connect->query("SELECT * FROM user WHERE user_username='".$user."'");
    return isNumRowExist($query);
}

function getUserInfo($user) {
    global $connect;
    $query = $connect->query("SELECT * FROM user WHERE user_username='".$user."'");

    return $query->fetch_assoc();
}

function getDateAtTheMoment() {
    $date = date("Y-m-d H:i:s");
    return $date;
}

function getUsernameWithUserId($userID) {
    global $connect;

    $queryUserName = $connect->query("SELECT * FROM user WHERE user_id = '".$userID."'");
    $queryUser = $queryUserName->fetch_assoc();
    return $queryUser["user_username"];
}

function echoJsonArray($gArray) {
    echo json_encode($gArray, true);
}

function isNumRowExist($gQuery) {
    if($gQuery->num_rows>=1) return true;
    return false;
}

?>