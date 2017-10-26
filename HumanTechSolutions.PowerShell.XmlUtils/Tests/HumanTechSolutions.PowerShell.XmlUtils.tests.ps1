#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

#BEGIN IMPORTING MODULE
#Set module's path to the parent
$pathToFindModules = (Split-Path $PSCommandPath | Split-Path)
$modules = @()
#Get all psd1 (aka modules) into @modules array
Get-ChildItem -Path $pathToFindModules -Filter "*.psd1" |
	ForEach-Object { $modules += Test-ModuleManifest -Path $_.FullName }
#remove and then import each found module
$modules |
	ForEach-Object { 
		Remove-Module -Name $_.Name -ErrorAction Ignore
		Import-Module $_
	}
#END IMPORTING MODULE

#BEGIN TESTS
Describe "Test-Xml" {
	Context "Function Exists" {
		It "Should Exist" {
			$textXmlFunction = Get-Command -Name "Test-Xml" -Module $moduleName -ErrorAction Ignore
			$textXmlFunction | Should Be $true
		}
	}
	Context "Function Parameters" {
		$xmlFilePath = Join-Path $TestDrive 'functionparameters.xml'
		Set-Content -Path $xmlFilePath -Value "<xml></xml>"
		It "Should test for mandatory parameters" {
			$xmlFilePathMandatory =  (Get-Command -Name "Test-Xml").Parameters["Path"].Attributes.Mandatory
			$xmlFilePathMandatory | Should Be $true
		}
		It "Should works without explicit parameter name" {
			{Test-Xml $xmlFilePath} | Should Not Throw
		}
		It "Should works with explicit parameter name" {
			{Test-Xml -Path $xmlFilePath} | Should Not Throw
		}
		It "Should works with parameter alias" {
			(Get-Command -Name "Test-Xml").Parameters["Path"].Aliases | Should Be "FullName"
		}
	}
	Context "Pipeline Integration" {
		$xmlFilePath = Join-Path $TestDrive 'pipelineintegration.xml'
		Set-Content -Path $xmlFilePath -Value "<xml></xml>"
		It "Should accept pipeline from Get-Item" {
			{Get-Item -Path $xmlFilePath | Test-Xml} | Should Not Throw
		}
		It "Should accept pipeline from Get-ChildItem" {
			{Get-ChildItem -Path $xmlFilePath | Test-Xml} | Should Not Throw
		}
	}
	Context "XML Files cases" {
		It "Show error on invalid file path" {
			$xmlFilePath = Join-Path $TestDrive 'invalidfile.xml'
			{Test-Xml -Path $xmlFilePath} | Should Throw "Cannot validate argument on parameter 'Path'"
		}
		It "Valid File - No schemas" {
			$xmlFilePath = Join-Path $TestDrive 'validfilenoschemas.xml'
			Set-Content -Path $xmlFilePath -Value "<note><to>Tove</to><from>Jani</from><heading>Reminder</heading><body>Don't forget me this weekend!</body></note>"
			$result = Test-Xml -Path $xmlFilePath
			$result | Should BeOfType psobject
			$result.ValidXmlFile | Should Be $true
			$result.Error | Should Be ""
		}
		It "Valid File - Online schemas" {
			$xmlFilePath = Join-Path $TestDrive 'validfilenoschemas.xml'
			Set-Content -Path $xmlFilePath -Value "<?xml version='1.0' encoding='ISO-8859-1'?><?xml-stylesheet href='latest_ob.xsl' type='text/xsl'?><current_observation version='1.0' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='http://www.weather.gov/view/current_observation.xsd'><credit>NOAA's National Weather Service</credit><credit_URL>http://weather.gov/</credit_URL><image><url>http://weather.gov/images/xml_logo.gif</url><title>NOAA's National Weather Service</title><link>http://weather.gov</link></image><suggested_pickup>15 minutes after the hour</suggested_pickup><suggested_pickup_period>60</suggested_pickup_period><location>Seattle, Seattle-Tacoma International Airport, WA</location><station_id>KSEA</station_id><latitude>47.44472</latitude><longitude>-122.31361</longitude><observation_time>Last Updated on Oct 25 2017, 1:53 pm PDT</observation_time><observation_time_rfc822>Wed, 25 Oct 2017 13:53:00 -0700</observation_time_rfc822><weather>Overcast</weather><temperature_string>59.0 F (15.0 C)</temperature_string><temp_f>59.0</temp_f><temp_c>15.0</temp_c><relative_humidity>81</relative_humidity><wind_string>Southwest at 10.4 MPH (9 KT)</wind_string><wind_dir>Southwest</wind_dir><wind_degrees>210</wind_degrees><wind_mph>10.4</wind_mph><wind_kt>9</wind_kt><pressure_string>1019.4 mb</pressure_string><pressure_mb>1019.4</pressure_mb><pressure_in>30.08</pressure_in><dewpoint_string>53.1 F (11.7 C)</dewpoint_string><dewpoint_f>53.1</dewpoint_f><dewpoint_c>11.7</dewpoint_c><windchill_string>57 F (14 C)</windchill_string><windchill_f>57</windchill_f><windchill_c>14</windchill_c><visibility_mi>10.00</visibility_mi><icon_url_base>http://forecast.weather.gov/images/wtf/small/</icon_url_base><two_day_history_url>http://www.weather.gov/data/obhistory/KSEA.html</two_day_history_url><icon_url_name>ovc.png</icon_url_name><ob_url>http://www.weather.gov/data/METAR/KSEA.1.txt</ob_url><disclaimer_url>http://weather.gov/disclaimer.html</disclaimer_url><copyright_url>http://weather.gov/disclaimer.html</copyright_url><privacy_policy_url>http://weather.gov/notice.html</privacy_policy_url></current_observation>"
			$result = Test-Xml -Path $xmlFilePath
			$result | Should BeOfType psobject
			$result.ValidXmlFile | Should Be $true
			$result.Error | Should Be ""
		}
		It "Non closing tag" {
			$xmlFilePath = Join-Path $TestDrive 'invalidfilestructure.xml'
			Set-Content -Path $xmlFilePath -Value "<note><to>Tove</to><from>Jani</Ffrom><heading>Reminder</heading><body>Don't forget me this weekend!</body></note>"
			$result = Test-Xml -Path $xmlFilePath
			$result.ValidXmlFile | Should Be $false
			$result.Error | Should Not Be ""
		}
	}
}
#END TESTS

#BEGIN REMOVING MODULE
$modules | ForEach-Object { 
	Remove-Module -Name $_.Name
	}
#END REMOVING MODULE