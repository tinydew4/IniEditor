# IniEditor

ini edit helper

MUST! 아래 형태로 "실행파일명.ini" 이 있어야 동작한다.

>[Config]
Define=1
FileName=[target file name]

>[Type]
Define=1
ValueList=[ValueList]

>[Section/Value]
Type=[Type]

Define=1 이 있는 Section 은 값으로 처리 되지 않는다.
없는 경우는 값으로 처리되어 ValueList 에 나타난다.

Exmaple:

>[Config]
Define=1

>[Boolean]
Define=1
ValueList=0,1

>[HostList]
Define=1
ValueList="127.0.0.1,192.168.0.2"

>[SubWindow/Visible]
Type=Boolean

>[Magic/Enabled]
Type=Boolean

>[Remote/Main]
Type=HostList
