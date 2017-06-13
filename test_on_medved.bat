set VOLUMES_FOLDER=c:\Volumes\medved
set MAIN_FOLDER=0 - XPWork\Medvedevy\DmitryMedvedev
set EXCEPT_VOLUME=3 - System2016

call union_fs_by_junction.bat "%VOLUMES_FOLDER%" "%MAIN_FOLDER%" "%EXCEPT_VOLUME%"