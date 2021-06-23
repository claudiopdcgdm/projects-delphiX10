<h1>Simple App_wms</h1>
App_wms is simple project in delphi XE 10 for desktop application.

<h1>Pré-requirements</h1>
Rad Studio (Delphi 10), /
Data base postgres 10 in localhost;
S.O Windows 7 or 10
pgadmin 4 or 3 or other client db for postgres
<h1>Installation</h1>
NOTE: configure user/password for database postgres

user: postgres / pass: q1w2e3r4

configure variable enviroment in PATH

C:\Program Files\PostgreSQL\12\bin

Fallow:

clone https://github.com/claudiopdcgdm/projects-delphiX10.git and compile in raid Studio software

In terminal MS-DOS access directory from clone project.

SAMPLE : 'cd \users\user01\Documentos\embarcadero\studio\app_wms-original\db\sqls\db_app_wms.sql'

Execute fallow command line for import tables and functions e others for in db;
psql -U postgres app_wms < db_app_wms.sql

<h1>Usage</h1>
Execute app_wms.exe from path projects-delphiX10/Win32/Debug/

<h1>License</h1>
MIT

