<?php 

	$key = $_REQUEST['key'];
	$eventName = $_REQUEST['event_name'];

	$url = "https://maker.ifttt.com/trigger/".$eventName."/with/key/".$key;

	function requestUrl($url){

		$key = $_REQUEST['key'];
		$eventName = $_REQUEST['event_name'];

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)');
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
		curl_setopt($ch, CURLOPT_TIMEOUT, 5);
		$data = curl_exec($ch);

		    // Check for errors and display the error message
       		 if(curl_errno($ch)) {
             		error_log("cURL error: ". curl_error($ch)." - URL: ".$url."\n",3, "/tmp/error.log");
			return false;
     		 }else{ 
			error_log("Success: ".$url." - $data \n", 3, "/tmp/success.log"); 
			return true;
		 }
	}
	print_r(requestUrl($url));
