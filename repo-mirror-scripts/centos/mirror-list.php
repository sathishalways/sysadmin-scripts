<?php
$release = $_GET['release'];
$arch = $_GET['arch'];
$repo = $_GET['repo'];
header('Content-type: text/plain; charset=UTF-8');
$mirrors = array('http://mirror.mit.edu/centos', 'http://mirror.oss.ou.edu/centos', 'http://centos.mirror.lstn.net/centos');
foreach($mirrors as $mirror) {                                                                                                                                                                                                               
    echo trim($mirror)."/$release/$repo/$arch/\n";                                                                                                                                                                                           
} 
