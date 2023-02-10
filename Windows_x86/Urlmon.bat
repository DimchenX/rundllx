@echo off
set URLDTF=192.168.0.2
rundllx urlmon.dll URLDownloadToFileA 0 0 P%URLDTF%.html Phttp://%URLDTF%/index.html 0 R Di
pause