<?php

echo "sending mail";

$from = "button@pragmatic1.com";
$to = $_REQUEST['phone'];
$mesg = $_REQUEST['mesg'];

$code = $_REQUEST['code'];

if($code == 'bahay0210'){

        $headers = 'From: '.$from. ' <'.$from.'>' . "\r\n" .
                   'Reply-To: '.$from. "\r\n" .
                    'X-Mailer: PHP/' . phpversion();

        $ret = mail($to, '',$mesg,$headers,"-f"."$from");
}
