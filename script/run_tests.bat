start "TestWindow" cmd /k "java -D"java.library.path=G:\sdk\ddb\DynamoDBLocal_lib" -jar "G:\sdk\ddb\DynamoDBLocal.jar" -sharedDb -inMemory"
timeout /t 2 /nobreak > nul
dart run test
TASKKILL /F /T /FI "WindowTitle eq TestWindow*"