<?php
function isOnlyAscending($passAsText)
{
	$previous = ord('0');
	for($i = 0; $i < 6; $i++)
	{
		$digit = $passAsText[$i];
		$asciiValue = ord($digit);
		if($asciiValue < $previous)
		{
			return false;
		}
		$previous = $asciiValue;
	}
	return true;
}

function toInt($char)
{
	return ord($char) - ord('0');
}

function hasDouble($passAsText)
{
	$previous = $passAsText[0];
	$pairs = [null, null, null, null, null,
	          null, null, null, null, null];
	for($i = 1; $i < 6; $i++)
	{
		$current = $passAsText[$i];
		if($previous == $current)
		{
			$index = toInt($current);
			if($pairs[$index] === null)
			{
				$pairs[$index] = true;
			}
			else
			{
				$pairs[$index] = false;
			}
		}
		$previous = $current;
	}
	foreach($pairs as $pair)
	{
		if($pair) return true;
	}
	return false;
}

function isValidPassword($pass)
{
	$passAsText = strval($pass);
	return isOnlyAscending($passAsText) && hasDouble($passAsText);
}

echo "\n111111:", isValidPassword(111111) ? "true" : "false";
echo "\n111122:", isValidPassword(111122) ? "true" : "false";
echo "\n122333:", isValidPassword(111122) ? "true" : "false";
echo "\n112222:", isValidPassword(112222) ? "true" : "false";
echo "\n122345:", isValidPassword(122345) ? "true" : "false";
echo "\n123444:", isValidPassword(123444) ? "true" : "false";
echo "\n144444:", isValidPassword(144444) ? "true" : "false";
echo "\n124444:", isValidPassword(124444) ? "true" : "false";
echo "\n223450:", isValidPassword(223450) ? "true" : "false";
echo "\n123789:", isValidPassword(123789) ? "true" : "false";
$validPasswords = 0;
for ($x = 372037; $x < 905157; $x++)
{
	if(isValidPassword($x))
	{
		$validPasswords++;
	}
}

echo "\n";
echo strval($validPasswords);
?>
