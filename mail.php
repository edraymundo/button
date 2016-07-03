<?php
echo "Sending mail....<br>";
$from = "button@pragmatic1.com";
$to = $_REQUEST['phone'];
$mesg = $_REQUEST['mesg'];
$code = $_REQUEST['code'];
if($code == 'bahay0210'){
        try{
                $headers = 'From: '.$from. ' <'.$from.'>' . "\r\n" .
                           'Reply-To: '.$from. "\r\n" .
                           'X-Mailer: PHP/' . phpversion();
                mail($to, '',$mesg,$headers,"-f"."$from");
        }catch (Exception $e){
                echo "Failed: $e->getMessage()<br>";
                exit;
        }
        echo "Success";
}
