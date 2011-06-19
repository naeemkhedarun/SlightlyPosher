@echo off
powershell -NoProfile -ExecutionPolicy unrestricted -Command "& '.\update.ps1' %*"
pause