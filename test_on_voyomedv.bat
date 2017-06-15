@set VOLUMES_FOLDER=c:\Volumes\VOYOMEDV
@set MAIN_FOLDER=System\Medvedevy\DmitryMedvedev
@set EXCEPT_VOLUME=System

@call union_fs_by_junction.bat "%VOLUMES_FOLDER%" "%MAIN_FOLDER%" "%EXCEPT_VOLUME%"