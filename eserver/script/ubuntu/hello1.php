<?php 

$mysqli = new 	mysqli("192.168.1.148:3306","fxgame","fuxing", "pork_game") or die ("db can not connect");

//echo 3;
$mysqli->query("SET NAMES 'utf8'");
ini_set('max_execution_time', '0');
//mysql_query("SET NAMES 'gb2312'");
  //mysql_query("set character_set_client=utf8");  
   // mysql_query("set character_set_results=utf8"); 
$filesnames = scandir('G:\xampp\htdocs\PublicTables');
$temp='G:\xampp\htdocs\PublicTables';
global $newarr;
global $str3;
global $fieldNum;
// print_r ($filesnames);
$ln= 0; 
foreach ($filesnames as $name) {
	if($ln<2)
	{
		++$ln;
		continue;
	}
	$s='\\';
	$filepath=$temp.$s.$name;
	$arr = explode(".",$name); 
    $basename=$arr[0];
	//echo $filepath;
	//echo $basename;
	
	
$f = fopen ($filepath, "r"); 

$lin=1;
while (! feof ($f)) { 
 $line= fgets ($f); 
 $num=strlen($line);
// echo $num;
// echo "付星";
// if(strlen($line)<3 )  
	//{
	//   continue;
	//}
	if($line[0]=='#')
	{
		
		continue;
	}
	if($lin==1)
	{
		
		//echo $str3;
		$lin++;
		continue;
	}
	
  $str2=')';
  $str4=' '; 
  $point='.';
  $test1='Fx_Db';
	  $str5=',';
  $str='CREATE TABLE ';
	 $str1='(';
	 $str3=$str.$basename.$str1;
 $insertstr='INSERT INTO ';
$temp3='VALUES';
$insertstr=$insertstr.$test1.$point.$basename.$str1;
//echo $str3;
//$insertstr=$insertstr.$test1.$point.$basename.$str4.$temp3.$str1;
$k=0;


 if(isset($newarr))
 { foreach($newarr as $u)
	{ 
		//echo 4;

		if ($k == $fieldNum)
		{
			break;
		}
		//echo $insertstr;
		$insertstr=$insertstr.strtolower($u).$str5;
		//echo $u;
		//echo 8;
		//echo $insertstr;
		++$k;
	} 
 }  

	 $insertstr= substr($insertstr,0,strlen($insertstr)-1); 
	 $insertstr= $insertstr.$str2.$temp3.$str1;
	 //echo 8;
	// echo $insertstr;
	 //echo 9;
 
 //echo  $line;


	 
 if($lin==2)
	 
 { 
	//echo $line;
	//echo 2;
	//echo $line;
	//echo "hello\n";
	$newarr= explode("\t",$line);
	++$lin;
	continue;
   
 }  

    //  print_r ($newarr);
	

elseif($lin==3)
 {
 	//echo 3;
	//echo $line;
	//echo 9;
	$str9 = $line."\t";
	 $newarr1 = explode("\t",$str9);
	 $k=0;
	$fieldNum = sizeof($newarr1);
	//echo $newarr1[4];
	 foreach($newarr as $u)
	 { 
		
		//echo $newarr1[$k];
		if ($k == $fieldNum)
		{
			break;
		}
		
		//echo $newarr[$k];
		//echo $newarr1[$k];
		//echo $k;
	echo $newarr1[$k];	
	if($newarr1[$k]=='STRING')
	{
		echo $k;
		$newarr1[$k]='Text';
	}
	
			
	
			$str3=$str3.strtolower($u).$str4.$newarr1[$k].$str5;
	
			++$k;
		
	
	 } 
    //echo $newarr1[4];
	 $str3= substr($str3,0,strlen($str3)-1); 

	 $str3=$str3.$str2;
	 $str3=$str3.'DEFAULT CHARSET =UTF8';
	 echo $str3;
	 //echo $str3;
	 
	$mysqli->query($str3);


	++$lin;
	 //print_r ($newarr);
	  //print_r ($newarr1);
	 continue;
 }
 else
 {
	 $fielf= explode("\t",$line);
	 $k=0;
	 foreach($fielf as $m) 
	 {
		
		if ($k == $fieldNum)
		{
			break;
		}
	  
	 $encoding = mb_detect_encoding($m, array('GB2312','GBK','UTF-16','UCS-2','UTF-8','BIG5','ASCII'));
        if ($encoding != false) 
		{
			 $m = iconv($encoding, 'UTF-8', $m);
		}
		else 
		{

           $m = mb_convert_encoding ( $m, 'UTF-8','Unicode');

		}

		 $a1=sprintf("'%s'",$m);
		 
		 //$a1 = iconv('utf-8','gb2312',$m);
		 //echo $a1;
		$insertstr=$insertstr.$a1.$str5;
		++$k;
	 }
	 $insertstr= substr($insertstr,0,strlen($insertstr)-1); 
	 $insertstr=$insertstr.$str2;
	 echo  $insertstr;
	  $mysqli->query($insertstr);
	continue;
	
 }
   
   
   
	
} 
fclose ($f);  

}


?>






