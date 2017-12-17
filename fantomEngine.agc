#option_explicit

#constant True = 1
#constant False = 0


global ftObjList as ftObject[]
global ftfreeObjList as integer[]

#constant KEY_BACK      =  8
#constant KEY_TAB       =  9
#constant KEY_ENTER     =  13
#constant KEY_SHIFT     =  16
#constant KEY_CONTROL   =  17
#constant KEY_ESCAPE    =  27
#constant KEY_SPACE     =  32
#constant KEY_PAGEUP    =  33
#constant KEY_PAGEDOWN  =  34
#constant KEY_END       =  35
#constant KEY_HOME      =  36
#constant KEY_LEFT      =  37
#constant KEY_UP        =  38
#constant KEY_RIGHT     =  39
#constant KEY_DOWN      =  40
#constant KEY_INSERT    =  45
#constant KEY_DELETE    =  46
#constant KEY_0         =  48
#constant KEY_1         =  49
#constant KEY_2         =  50
#constant KEY_3         =  51
#constant KEY_4         =  52
#constant KEY_5         =  53
#constant KEY_6         =  54
#constant KEY_7          = 55
#constant KEY_8          = 56
#constant KEY_9          = 57
#constant KEY_A          = 65
#constant KEY_B          = 66
#constant KEY_C          = 67
#constant KEY_D          = 68
#constant KEY_E          = 69
#constant KEY_F          = 70
#constant KEY_G          = 71
#constant KEY_H          = 72
#constant KEY_I          = 73
#constant KEY_J          = 74
#constant KEY_K          = 75
#constant KEY_L          = 76
#constant KEY_M          = 77
#constant KEY_N          = 78
#constant KEY_O          = 79
#constant KEY_P          = 80
#constant KEY_Q          = 81
#constant KEY_R          = 82
#constant KEY_S          = 83
#constant KEY_T          = 84
#constant KEY_U          = 85
#constant KEY_V          = 86
#constant KEY_W          = 87
#constant KEY_X          = 88
#constant KEY_Y          = 89
#constant KEY_Z          = 90
#constant KEY_F1         = 112
#constant KEY_F2         = 113
#constant KEY_F3         = 114
#constant kEY_F4         = 115
#constant KEY_F5         = 116
#constant KEY_F6         = 117
#constant KEY_F7         = 118
#constant KEY_F8         = 119
#constant KEY_F9         = 120
#constant KEY_F10        = 121
#constant KEY_F11        = 122
#constant KEY_F12        = 123

#constant ctCircle = 1
#constant ctBox = 2
#constant ctPolygon = 3

//-----------------------------------------------------
type ftObject
	deleted as integer
	spr as integer
	id as integer
	layer as integer
	
	speed as float
	speedX as float
	speedY as float
	speedAngle as float
	speedSpin as float
	
	friction as float
	speedMax as float
	speedMin as float
	isWrappingX as integer
	isWrappingY as integer
	
	timerList as ftTimer[]
	
	colGroup as integer
	doCollision as integer
	doTouchCheck as integer
	colWith as integer[]
	
	tweenID as integer
	tweenSpr as integer
	parent as integer
	childList as integer[]

endtype

//-----------------------------------------------------
type ftTimer
	durance as float
	id as integer
endtype

//-----------------------------------------------------
function CreateObject(img as integer)
	local retval as integer
	local newObj as ftObject

	if ftfreeObjList.length > -1
		//retval = ftfreeObjList[ftfreeObjList.length]
		retval = ftfreeObjList[0]
		//ftfreeObjList.remove()
		ftfreeObjList.remove(0)
		ftObjList[retval].deleted = false
		if img > 0	
			ftObjList[retval].spr = CreateSprite(img)
			//SetSpriteScale(ftObjList[retval].spr, 1.0, 1.0)
		endif
		
		ftObjList[retval].id = 0
		ftObjList[retval].speed = 0.0
		ftObjList[retval].speedX = 0.0
		ftObjList[retval].speedY = 0.0
		ftObjList[retval].speedAngle = 0.0
		ftObjList[retval].speedSpin = 0.0
		ftObjList[retval].friction = 0.0
		ftObjList[retval].speedMax = 100.0
		ftObjList[retval].speedMin= 0.0
		ftObjList[retval].isWrappingX = false
		ftObjList[retval].isWrappingY = false
		ftObjList[retval].timerList.length = -1
		ftObjList[retval].colGroup = 0
		ftObjList[retval].tweenID = 0
		ftObjList[retval].tweenSpr = 0
		ftObjList[retval].doCollision = 0
		ftObjList[retval].colWith.length = -1 
		ftObjList[retval].parent = -1
		ftObjList[retval].childList.length = -1
		ftObjList[retval].doTouchCheck = 0
		ftObjList[retval].layer = 0
	else
		if img > 0
			newObj.spr = CreateSprite(img)
			//SetSpriteScale(newObj.spr, 1.0, 1.0)
		endif
		newObj.speedMax = 100.0
		newObj.parent = -1
		//newObj.timer01 = -0.01
		ftObjList.insert(newObj)
		retval = ftObjList.length
		//log ("New="+str(retval))
	endif
endfunction retval

//-----------------------------------------------------
function CreateTimer(obj as integer, id as integer, durance as float)
	local newTimer as ftTimer
	newTimer.durance = durance
	newTimer.id = id
	ftObjList[obj].timerList.insert(newTimer)
endfunction
//-----------------------------------------------------
function AddAngle(obj as integer, angle#)
	//SetSpriteAngle(obj.spr, angle#+GetSpriteAngle(obj.spr))
	SetAngle(obj, angle#+GetAngle(obj))
endfunction
	
//-----------------------------------------------------
function AddPos(obj as integer, xPos#, yPos#)
	local ch as integer
	local chl as integer
	chl = ftObjList[obj].childList.length
	if chl >= 0
		for ch = 0 to chl
			AddPos(ftObjList[obj].childList[ch], xPos#, yPos#)
		next
	endif
	xPos# = xPos# + GetPosX(obj)
	yPos# = yPos# + GetPosY(obj)
	SetPos(obj,xpos#,ypos#)
endfunction
//-----------------------------------------------------
function AddPosX(obj as integer, xPos#)
	xPos# = xPos# + GetPosX(obj)
	SetPosX(obj,xpos#)
endfunction
//-----------------------------------------------------
function AddPosY(obj as integer, yPos#)
	yPos# = yPos# + GetPosY(obj)
	SetPosY(obj,ypos#)
endfunction

//-----------------------------------------------------
function CheckAllCollisions()
	local oc as integer
	local ind1 as integer
	local ind2 as integer
	local colGrp as integer
	local cgL as integer
	oc = ftObjList.length
	for ind1 = 0 to oc
		if ftObjList[ind1].deleted = false 
			if ftObjList[ind1].colGroup > 0 and GetActive(ind1) = True 
				if ftObjList[ind1].doCollision = True
//Print("ID="+str(GetID(ind1)))
					cgL = ftObjList[ind1].colWith.length
//Print("cgL="+str(cgL))
					for colGrp = 0 to cgl 
						for ind2 = 0 to oc
							if ftObjList[ind2].colGroup = ftObjList[ind1].colWith[colGrp]
								if ftObjList[ind1].spr <> -1 and ftObjList[ind2].spr <> -1
									if GetSpriteCollision ( ftObjList[ind1].spr, ftObjList[ind2].spr ) = 1
										OnObjCollision(ind1,ind2)
									endif
								endif
							endif
						next
					next
				endif
			endif
		endif 
	next
 
endfunction

//-----------------------------------------------------
function CheckAllTouches(px as integer, py as integer)
	local oc as integer
	local ind1 as integer
	local ind2 as integer
	local colGrp as integer
	local cgL as integer
	oc = ftObjList.length
	for ind1 = 0 to oc
		if GetActive(ind1) = True 
			if ftObjList[ind1].deleted = false 
				if ftObjList[ind1].doTouchCheck = True
					if GetSpriteHitTest ( ftObjList[ind1].spr,px, py) = 1
						OnObjTouch(ind1)
					endif
				endif
			endif 
		endif 
	next
 
endfunction
//-----------------------------------------------------
function AddSpeed(obj as integer, sp as float, angle as float)
	Local a as Float
	a = angle

	ftObjList[obj].speedX = ftObjList[obj].speedX + Sin(a) * sp
	ftObjList[obj].speedY = ftObjList[obj].speedY - Cos(a) * sp
	a= ATan2( ftObjList[obj].speedY, ftObjList[obj].speedX )+90.0
	If a < 0.0 
		a = a + 360.0
	Else
		If a > 360.0 
			a = a - 360.0
		Endif
	Endif
	ftObjList[obj].speedAngle = a 
	ftObjList[obj].speed = Sqrt(ftObjList[obj].speedX * ftObjList[obj].speedX + ftObjList[obj].speedY * ftObjList[obj].speedY)
	If ftObjList[obj].speed > ftObjList[obj].speedMax Then ftObjList[obj].speed = ftObjList[obj].speedMax	
endfunction

//-----------------------------------------------------
function GetActive(obj as integer)
	local retVal as integer
	if ftObjList[obj].spr > 0
		retVal = GetSpriteActive(ftObjList[obj].spr)
	else
		retVal = False
	endif
endfunction retVal

//-----------------------------------------------------
function GetAlpha(obj as integer)
	local retVal as integer
	retVal = GetSpriteColorAlpha(ftObjList[obj].spr)
endfunction retVal

//-----------------------------------------------------
function GetAngle(obj as integer)
	local retVal as float
	retVal = GetSpriteAngle(ftObjList[obj].spr)
endfunction retVal

//-----------------------------------------------------
function GetColGroup(obj as integer)
	local retVal as integer
	retval = ftObjList[obj].colGroup
endfunction retVal

//-----------------------------------------------------
function GetHeight(obj as integer)
	local retVal as integer
	retVal = GetSpriteHeight(ftObjList[obj].spr)
endfunction retVal

//-----------------------------------------------------
function GetID(obj as integer)
	local retVal as integer
	retVal = ftObjList[obj].ID
endfunction retVal

//-----------------------------------------------------
function GetLayer(obj as integer)
	local retVal as integer
	retVal = ftObjList[obj].layer
endfunction retVal

//-----------------------------------------------------
function GetObjectCount()
	local retVal as integer
	retVal = ftObjList.length + 1
endfunction retVal

//-----------------------------------------------------
function GetPosX(obj as integer)
	local retVal as float
	retVal = GetSpriteXByOffset(ftObjList[obj].spr)
endfunction retVal

//-----------------------------------------------------
function GetPosY(obj as integer)
	local retVal as float
	retVal = GetSpriteYByOffset(ftObjList[obj].spr)
endfunction retVal

//-----------------------------------------------------
function GetSpeed(obj as integer)
	local retVal as float
	retVal = ftObjList[obj].speed
endfunction retVal

//-----------------------------------------------------
function GetSpeedAngle(obj as integer)
	local retVal as float
	retVal = ftObjList[obj].speedAngle
endfunction retVal

//-----------------------------------------------------
function GetSprite(obj as integer)
	local retVal as integer
	retVal = ftObjList[obj].spr
endfunction retVal

//-----------------------------------------------------
function GetTargetAngle(obj as integer, target as integer, relative as integer)
	Local xdiff as Float
	Local ydiff as Float 
	Local ang as Float
		
	xdiff = GetPosX(target) - GetPosX(obj)
	ydiff = GetPosY(target) - GetPosY(obj)
		
	ang = ATan2( ydiff, xdiff )+90.0
	If ang < 0 
		ang = 360.0 + ang
	Endif
	If relative=True
		ang = ang - GetAngle(obj)
		If ang > 180.0
			ang = ang - 360.0
		Elseif ang < -180.0
			ang = ang + 360.0
		Endif
	Endif
endfunction ang


//-----------------------------------------------------
function GetTween(obj as integer)
	local retVal as integer
	retVal = ftObjList[obj].tweenID
endfunction retVal

//-----------------------------------------------------
function GetVector(obj as integer, vecDistance as float, vecAngle as float, relative as integer)
	Local v as Float[2]
	Local a as Float
	If relative = True
		a = GetAngle(obj) + vecAngle
	Else
		a = vecAngle
	Endif
	v[0] = GetPosX(obj) + Sin(a) * vecDistance
	v[1] = GetPosY(obj) - Cos(a) * vecDistance
endfunction v

//-----------------------------------------------------
function GetVisible(obj as integer)
	local retVal as integer
	retVal = GetSpriteVisible(ftObjList[obj].spr)
endfunction retVal

//-----------------------------------------------------
function GetWidth(obj as integer)
	local retVal as integer
	retVal = GetSpriteWidth(ftObjList[obj].spr)
endfunction retVal

//-----------------------------------------------------
function RemoveAllObjects()
	local oc as integer
	local ind as integer
	oc = ftObjList.length
	for ind = 0 to oc
		if ftObjList[ind].deleted = false then	RemoveObject(ind)
	next
endfunction

//-----------------------------------------------------
function RemoveObject(obj as integer)
	local ch as integer
	local chl as integer
	chl = ftObjList[obj].childList.length
	if chl >= 0
		for ch = 0 to chl
			RemoveObject(ftObjList[obj].childList[ch])
		next
	endif
	if GetTween(obj) > 0 
		StopTweenSprite(ftObjList[obj].tweenID,ftObjList[obj].spr)
		DeleteTween(ftObjList[obj].tweenID)
	endif
	DeleteSprite(ftObjList[obj].spr)
	ftObjList[obj].spr = -1
	ftObjList[obj].deleted = True
	ftObjList[obj].id = -1
	ftfreeObjList.insert(obj)
endfunction

//-----------------------------------------------------
function SetActive(obj as integer, flag as integer)
	if ftObjList[obj].spr > 0 then SetSpriteActive(ftObjList[obj].spr,flag)
endfunction

//-----------------------------------------------------
function SetAlpha(obj as integer, alpha)
	SetSpriteColorAlpha(ftObjList[obj].spr,alpha)
endfunction

//-----------------------------------------------------
function SetAngle(obj as integer, angle#)
	SetSpriteAngle(ftObjList[obj].spr, angle#)
endfunction
	
//-----------------------------------------------------
function SetColor(obj as integer, red, green, blue)
	SetSpriteColor(ftObjList[obj].spr,red, green, blue, GetSpriteColorAlpha(ftObjList[obj].spr))
endfunction

//-----------------------------------------------------
function SetFriction(obj as integer, fric#)
	ftObjList[obj].friction = fric#
endfunction

//-----------------------------------------------------
function SetLayer(obj as integer, lay as integer)
	ftObjList[obj].layer = lay
endfunction

//-----------------------------------------------------
function SetLayerActive(lay as integer, flag as integer)
	local oc as integer
	local ind as integer
	oc = ftObjList.length
	for ind = 0 to oc
		if ftObjList[ind].layer = lay
			SetActive(ind, flag)
		endif
	next
 
endfunction
	
//-----------------------------------------------------
function SetLayerVisible(lay as integer, flag as integer)
	local oc as integer
	local ind as integer
	oc = ftObjList.length
	for ind = 0 to oc
		if ftObjList[ind].layer = lay 
			SetVisible(ind, flag)
		endif
	next
 
endfunction
	
//-----------------------------------------------------
function SetHandle(obj as integer, x#, y#)
	SetSpriteOffset( ftObjList[obj].spr, GetSpriteWidth(ftObjList[obj].spr)*x#, GetSpriteHeight(ftObjList[obj].spr)*y# ) 
endfunction
	
//-----------------------------------------------------
function SetID(obj as integer, id as integer)
	ftObjList[obj].id = id
endfunction
	
//-----------------------------------------------------
function SetColGroup(obj as integer, group as integer)
	SetSpriteGroup( ftObjList[obj].spr, group ) 
	ftObjList[obj].colGroup = group
endfunction

//-----------------------------------------------------
function SetColWith(obj as integer, colWith as integer, flag as integer)
	if flag = True
		ftObjList[obj].colWith.Insert(colWith) 
		ftObjList[obj].doCollision = True
	endif
endfunction

//-----------------------------------------------------
function SetColType(obj as integer, typ)
	SetSpriteShape( ftObjList[obj].spr, typ ) 
endfunction

//-----------------------------------------------------
function SetParent(obj as integer, par as integer)
	ftObjList[obj].parent = par
	ftObjList[par].childList.insert(obj) 
endfunction

//-----------------------------------------------------
function SetPos(obj as integer, xpos#, ypos#)
	SetSpritePositionbyOffset(ftObjList[obj].spr,xpos#,ypos#)
endfunction

//-----------------------------------------------------
function SetPosX(obj as integer, xpos#)
	SetSpritePositionByOffset(ftObjList[obj].spr,xpos#,GetSpriteYByOffset(ftObjList[obj].spr))
endfunction

//-----------------------------------------------------
function SetPosY(obj as integer, ypos#)
	SetSpritePositionByOffset(ftObjList[obj].spr,GetSpriteXByOffset(ftObjList[obj].spr), ypos#)
endfunction

//-----------------------------------------------------
function SetScale(obj as integer, scale#)
	SetSpriteScaleByOffset(ftObjList[obj].spr, scale#, scale#)
	//SetHandle(ftObjList[obj].spr, GetWidth(ftObjList[obj].spr)*scale#, GetHeight(ftObjList[obj].spr)*scale# )
endfunction

//-----------------------------------------------------
function SetScaleX(obj as integer, scale#)
	SetSpriteScaleByOffset(ftObjList[obj].spr, scale#, GetSpriteScaleY(ftObjList[obj].spr))
	//SetHandle(ftObjList[obj].spr, GetWidth(ftObjList[obj].spr)*scale#, GetHeight(ftObjList[obj].spr)*scale# )
endfunction

//-----------------------------------------------------
function SetScaleY(obj as integer, scale#)
	SetSpriteScaleByOffset(ftObjList[obj].spr, GetSpriteScaleX(ftObjList[obj].spr), scale#)
	//SetHandle(ftObjList[obj].spr, GetWidth(ftObjList[obj].spr)*scale#, GetHeight(ftObjList[obj].spr)*scale# )
endfunction

//-----------------------------------------------------
function SetShader(obj as integer, shader as integer)
	SetSpriteShader(ftObjList[obj].spr, shader)
endfunction

//-----------------------------------------------------
function SetSpeed(obj as integer, sp as float, angle as float)
	Local a as Float
	a = angle

	ftObjList[obj].speedX = Sin(a) * sp
	ftObjList[obj].speedY = -Cos(a) * sp
	a= ATan2( ftObjList[obj].speedY, ftObjList[obj].speedX )+90.0
	If a < 0.0 
		a = a + 360.0
	Else
		If a > 360.0 
			a = a - 360.0
		Endif
	Endif
	ftObjList[obj].speedAngle = a 
	ftObjList[obj].speed = Sqrt(ftObjList[obj].speedX * ftObjList[obj].speedX + ftObjList[obj].speedY * ftObjList[obj].speedY)
	If ftObjList[obj].speed > ftObjList[obj].speedMax Then ftObjList[obj].speed = ftObjList[obj].speedMax	
endfunction

//-----------------------------------------------------
function SetSpeedMax(obj as integer, speed#)
	ftObjList[obj].speedMax = speed#
endfunction

//-----------------------------------------------------
function SetSpin(obj as integer, spin#)
	ftObjList[obj].speedSpin = spin#
endfunction

//-----------------------------------------------------
function SetTouchCheck(obj as integer, touchFlag as integer)
	ftObjList[obj].doTouchCheck = touchFlag
endfunction

//-----------------------------------------------------
function SetTween(obj as integer, tween)
	ftObjList[obj].tweenID = tween
endfunction

//-----------------------------------------------------
function SetVisible(obj as integer, flag)
	SetSpriteVisible(ftObjList[obj].spr,flag)
endfunction

//-----------------------------------------------------
function SetWrapScreen(obj as integer, xFlag, yFlag)
	ftObjList[obj].isWrappingX = xFlag
	ftObjList[obj].isWrappingY = yFlag
endfunction


//-----------------------------------------------------
function UpdateAllObjects(delta as float)
	local oc as integer
	local ind as integer
	oc = ftObjList.length
	UpdateAllTweens( delta )
	for ind = 0 to oc
//Print ("UpdateAllObjects="+str(GetID(ftObjList[ind]))+":"+str(GetPosX(ftObjList[ind])))
		if ftObjList[ind].deleted = false 
			//if ftObjList[ind].parent = -1
				UpdateObject(ind, delta)
			//endif
		endif
	next
 
endfunction

//-----------------------------------------------------
function UpdateObject(obj as integer, delta as float)
	Local currSpeed as Float
	Local currFriction as Float
	Local absSpeedSpin as Float
	local tc as integer
	local ind as integer
	
	tc = ftObjList[obj].timerList.length
	
	for ind = tc to 0 step -1
		dec ftObjList[obj].timerList[ind].durance, delta
		if ftObjList[obj].timerList[ind].durance <= 0
			OnObjTimer(obj, ftObjList[obj].timerList[ind].id)
			ftObjList[obj].timerList.remove(ind)
		endif
	next
	
	OnObjUpdate(obj)
	if ftObjList[obj].deleted = true then exitfunction
	
	if ftObjList[obj].parent = -1
		currSpeed = ftObjList[obj].speed
		currFriction = ftObjList[obj].friction * delta
		absSpeedSpin = ftObjList[obj].speedSpin
		
		If currSpeed > 0.0 
			currSpeed = currSpeed - currFriction
			If currSpeed < currFriction  
				ftObjList[obj].speed  = 0.0
				ftObjList[obj].speedX = 0.0
				ftObjList[obj].speedY = 0.0
			Else
				ftObjList[obj].speed  = currSpeed
				ftObjList[obj].speedX = Sin(ftObjList[obj].speedAngle) * currSpeed
				ftObjList[obj].speedY = -Cos(ftObjList[obj].speedAngle) * currSpeed
				AddPos(obj, ftObjList[obj].speedX * delta , ftObjList[obj].speedY * delta)	

			Endif
		Elseif currSpeed < 0.0
			currSpeed = currSpeed + currFriction
			If currSpeed > currFriction  
				ftObjList[obj].speed  = 0.0
				ftObjList[obj].speedX = 0.0
				ftObjList[obj].speedY = 0.0
			Else
				ftObjList[obj].speed  = currSpeed
				ftObjList[obj].speedX = Sin(ftObjList[obj].speedAngle) * currSpeed
				ftObjList[obj].speedY = -Cos(ftObjList[obj].speedAngle) * currSpeed
				AddPos(obj, ftObjList[obj].speedX * delta, ftObjList[obj].speedY * delta)	
			Endif
		Endif
		If absSpeedSpin  <> 0.0 
			If absSpeedSpin < 0 Then absSpeedSpin = absSpeedSpin * -1.0
			If absSpeedSpin < currFriction 
				ftObjList[obj].speedSpin = 0.0
			Else
			   If ftObjList[obj].speedSpin > 0.0 
					ftObjList[obj].speedSpin = ftObjList[obj].speedSpin - currFriction
			   Else
					ftObjList[obj].speedSpin = ftObjList[obj].speedSpin + currFriction
			   Endif
			   AddAngle(obj, ftObjList[obj].speedSpin * delta)
			Endif
		Endif
	endif
	If ftObjList[obj].isWrappingX = True Then WrapScreenX(obj)
	If ftObjList[obj].isWrappingY = True Then WrapScreenY(obj)

	
endfunction

//-----------------------------------------------------
function WrapScreen(obj as integer)
	WrapScreenX(obj)
	WrapScreenY(obj)
endfunction

//-----------------------------------------------------
function WrapScreenX(obj as integer)
	local posX as integer
	posX = GetPosX(obj)
	if posX > GetVirtualWidth()
		SetPosX(obj, posX-GetVirtualWidth())
	endif
	if posX < 0
		SetPosX(obj, posX+GetVirtualWidth())
	endif
endfunction

//-----------------------------------------------------
function WrapScreenY(obj as integer)
	local posY as integer
	posY = GetPosY(obj)
	if posY > GetVirtualHeight()
		SetPosY(obj, posY-GetVirtualHeight())
	endif
	if posY < 0
		SetPosY(obj, posY+GetVirtualHeight())
	endif
endfunction

