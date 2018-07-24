	.data
	Date: .space 12	# 3 so nguyen 4 byte
	Date2: .space 12 # 3 so nguyen 4 byte (TIME2)
	smenu: .asciiz "\n----------Ban hay chon mot trong cac thao tac duoi day -----------\n1. Xuat chuoi TIME theo dinh dang DD/MM/YYYY\n2. Chuyen doi chuoi TIME thanh mot trong cac dinh dang sau:\n\tA. MM/DD/YYYY\n\tB. Month DD, YYYY\n\tC. DD Month, YYYY\n3. Cho biet ngay vua nhap la ngay thu may trong tuan\n4. Kiem tra nam trong chuoi TIME co phai la nam nhuan hay khong\n5. Cho biet khoang thoi gian giua chuoi TIME_1 va TIME_2\n6. Cho biet 2 nam nhuan gan nhat voi nam trong chuoi TIME\n----------------------------------------------------------------"
	sinp1: .asciiz "- Nhap ngay DAY: "
	sinp2: .asciiz "- Nhap thang MONTH: "
	sinp3: .asciiz "- Nhap nam YEAR: "
	sinp4: .asciiz "\n- Lua chon: "
	sinp5: .asciiz "\n- Ket qua: "
	sinp6: .asciiz "\n- Ban muon chuyen doi ngay sang dang nao: "	
	sinp7: .asciiz "\n- Hai nam nhuan gan nhat la: "
	sinp8: .asciiz "\n- Nhap NGAY, THANG, NAM cua DATE_2: \n"
	sinp9: .asciiz "\n- Khoang thoi gian (NGAY) giua 2 chuoi TIME_1 va TIME_2: "
	sbuffer: .space 6
	sslash: .asciiz "/"
	snewline: .asciiz "\n"
	sleapyear: .asciiz "Nam ban nhap la nam nhuan.\n"
	snotleap: .asciiz "Nam ban nhap khong la nam nhuan.\n"
	stest: .asciiz "11/11/1600"
	sTIME1: .space 20	#Vung nho cho chuoi TIME1
	sTIME2: .space 20	#Vung nho cho chuoi TIME2	
	dayOfMonth: .byte 31,28,31,30,31,30,31,31,30,31,30,31
	ArrDayOfWeek: .ascii "Sun","Mon","Tues","Wed","Thurs","Fri","Sat",
	sizeWeek: .word 0,3,6,10,13,18,21,24
	DayOfWeek: .space 10
	#Mang chua ten thang va chieu dai cua tung ten thang
	sMonths: .asciiz "January","February","March","April","May","June","July","August","September","October","November","December"
	sizeMonth: .word 0,8,17,23,29,33,38,43,50,60,68,77
	numDaysInMonth: .word 0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
	.text
main:
	la $s0,Date	#s0 -> Date


## MENU ##
menu:
	#Truyen vao - khong dung bien toan cuc
	addi $a0,$s0,0
	jal inputDAY
	jal inputMONTH
	jal inputYEAR

	#Goi ham char* Date(int,int,int,char*) truyen vao so va chieu dai chuoi can tra ve
	lw $a0,0($s0)
	lw $a1,4($s0)
	lw $a2,8($s0)
	la $a3,sTIME1
	jal charDate
	
	#In menu
	addi $v0, $0, 4
	la $a0, smenu
	syscall

ChoiceMenu:
	#In "Lua chon: "
	addi $v0, $0, 4
	la $a0, sinp4
	syscall

	#Nhap thao tac
	addi $v0, $0, 5
	syscall

	#Luu lai thao tac vao %t0
	addi $t0, $v0, 0

	#Xu ly
	addi $t1, $0, 1
	beq $t0, 1, mainPrintDATE
	addi $t1, $0, 2
	beq $t0, 2, mainConvert
	addi $t1, $0, 3
	beq $t0, 3, mainDayOfTheDate
	addi $t1, $0, 4
	beq $t0, 4, mainCheckLeap
	addi $t1, $0, 5
	beq $t0, 5, mainGetTime
	addi $t1, $0, 6
	beq $t0, 6, mainTwoNearestLeap
	#Nhap sai thi bat nhap lai
	slt $t1,$t0,$0
	bne $t1,$0,ChoiceMenu
	addi $t3,$0,6
	slt $t1,$t3,$t0
	bne $t1,$0,ChoiceMenu
## KET THUC MENU

## NHAP NGAY THANG NAM ##

inputDAY:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	sw $a0, 0($sp)

inputDAYtext:	
	addi $v0,$0,4	#Syscall 4: Print string DAY
	la $a0,sinp1	
	syscall
	
	addi $v0,$0,8	#Syscall 8: Read string
	la $a0,sbuffer
	addi $a1,$0,6	#Buffer length = 5
	syscall
	
	jal aton

	#Kiem tra ngay
	bne $v1,$0,inputDAYtext
	
	
	addi $t1, $0, 31
	slt $t0, $t1, $v0
	bne $t0, $0, inputDAYtext
	
	lw $a0,0($sp)
	addi $sp,$sp,4
	sw $v0,0($a0)	#Put DAY into a0 struct
	
	
	lw $ra, 0($sp)
	addi $sp,$sp,4
	jr $ra
	
inputMONTH:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)

inputMONTHtext:
	#Save struct address
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	addi $v0,$0,4	#Syscall 4: Print string MONTH
	la $a0,sinp2	
	syscall
	
	addi $v0,$0,8	#Syscall 8: Read string
	la $a0,sbuffer
	addi $a1,$0,6	#Buffer length = 5
	syscall
	
	jal aton
	
	lw $a0,0($sp)
	addi $sp,$sp,4
	
	#Kiem tra thang
	bne $v1,$0,inputMONTHtext

	
	addi $t1, $0, 12
	slt $t0, $t1, $v0
	bne $t0, $0, inputMONTHtext
	
	slt $t0,$v0,$0
	bne $t0,$0,inputMONTHtext
	

	la $t0, numDaysInMonth
	sll $t1, $v0, 2
	add $t0, $t0, $t1
	lw $t2, 0($t0)
	lw $t3, 0($a0)
	slt $t0, $t2, $t3
	bne $t0, $0, inputMONTHtext
	

	sw $v0,4($a0)	#Put MONTH into s struct

	lw $ra, ($sp)
	addi $sp,$sp,4
	jr $ra
	
inputYEAR:
		
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	

inputYEARtext:
	#Save struct address
	addi $sp,$sp,-4
	sw $a0, 0($sp)

	addi $v0,$0,4	#Syscall 4: Print string YEAR
	la $a0,sinp3	
	syscall
	
	addi $v0,$0,8	#Syscall 8: Read string
	la $a0,sbuffer
	addi $a1,$0,6	#Buffer length = 5
	syscall
	
	jal aton
	lw $a0,0($sp)
	addi $sp,$sp,4
	
	
	#Kiem tra nam co phai la so khong
	bne $v1,$0,inputYEARtext

	#Luu nam lai neu dung la so
	addi $sp,$sp,-4
	sw $v0,0($sp)
	
	addi $t1, $0, 1900
	slt $t2, $v0, $t1
	bne $t2, $0, inputYEARtext

	lw $t1, 4($a0)
	addi $t2, $0, 2
	bne $t1, $t2, out
	
	addi $sp,$sp,-4
	sw $a0,0($sp)
	
	addi $a0, $v0, 0
	jal leapYear
	lw $a0,0($sp)
	addi $sp,$sp,4
	beq $v0, $0, out 

	lw $t1, 0($a0)
	addi $t2, $0, 28
	slt $t3, $t2, $t1
	bne $t3, $0, inputYEARtext
	
out:
	lw $v0,0($sp)
	addi $sp,$sp,4
	sw $v0,8($a0)	#Put YEAR into s struct	
	lw $ra, ($sp)
	addi $sp,$sp,4
	jr $ra
## KET THUC NHAP NGAY - THANG - NAM. ##

## THAO TAC 1: ##
mainPrintDATE:
	#In "Ket qua: "
	addi $v0, $0, 4
	la $a0, sinp5
	syscall

	addi $v0,$0,4
	la $a0,snewline
	syscall
	
	la $a0,sTIME1
	addi $v0,$0,4	#Syscall 4: Print string
	syscall
	
	addi $v0,$0,4
	la $a0,snewline
	syscall

	addi $v0, $0, 10
	syscall
## KET THUC THAO TAC 1. ##

## THAO TAC 2: ##
mainConvert:
	la $a0,sinp6	#Syscall 4: Print string: Ban muon chuyen doi ntn
	addi $v0,$0,4
	syscall
		
	addi $v0,$0,12
	syscall
	
	add $a1,$v0,$0
	la $a0,sTIME1
	jal charConvert

	#In "Ket qua: "
	addi $v0, $0, 4
	la $a0, sinp5
	syscall
	
	#New line
	addi $v0,$0,4	#Syscall 4: Print string
	la $a0,snewline
	syscall
	
	addi $v0,$0,4	#Syscall 4: Print string
	la $a0,sTIME1
	syscall

endProg:
	addi $v0,$0,10
	syscall
## KET THUC THAO TAC 2. ##

## THAO TAC 3: ##
mainDayOfTheDate:
	#In "Ket qua: "
	addi $v0, $0, 4
	la $a0, sinp5
	syscall

	la $a0, sTIME1
	jal charDayOfWeek

	la $a0, ($v0)
	addi $v0, $0, 4
	syscall

	addi $v0, $0, 10
	syscall
## KET THUC THAO TAC 3. ##
	
## THAO TAC 4: ##
mainCheckLeap:
	#In "Ket qua: "
	addi $v0, $0, 4
	la $a0, sinp5
	syscall

	la $a0,sTIME1
	jal charLeapYear
	beq $v0,$0,L1
	
	addi $v0,$0,4
	la $a0,sleapyear
	syscall
	j outL
L1:
	addi $v0,$0,4
	la $a0,snotleap
	syscall
outL:
	addi $v0,$0,10
	syscall
## KET THUC THAO TAC 4. ##

## THAO TAC 5: ##
mainGetTime:
	
	addi $v0, $0, 4
	la $a0, sinp8
	syscall
	
	la $s0, Date2
	addi $a0, $s0, 0
	jal inputDAY
	jal inputMONTH
	jal inputYEAR

	#Goi ham char* Date(int,int,int,char*) truyen vao so va chieu dai chuoi can tra ve
	
	lw $a0,0($s0)
	lw $a1,4($s0)
	lw $a2,8($s0)
	la $a3,sTIME2
	jal charDate

	addi $v0, $0, 4
	la $a0, sinp9
	syscall	
	
	la $a0, sTIME1
	la $a1, sTIME2
	jal GetTime
	
	add $a0, $v0, $0
	addi $v0, $0, 1
	syscall

	addi $v0, $0, 10
	syscall
## KET THUC THAO TAC 5. ##

## THAO TAC 6: ##
mainTwoNearestLeap:
	#In "Hai nam nhuan gan nhat la: "
	addi $v0, $0, 4
	la $a0, sinp7
	syscall

	#Lay nam trong chuoi TIME
	la $a0, sTIME1
	jal intYear

	addi $s1, $v0, 1
	addi $t1, $0, 2
loop:
	beq $t1, $0, exit
	addi $a0, $s1, 0
	jal leapYear
	beq $v0, $0, repeat

	#In nam nhuan $t0
	addi $v0, $0, 1
	addi $a0, $s1, 0
	syscall
	#In khoang trang
	addi $v0, $0, 11
	addi $a0, $0, 32
	syscall

	addi $t1, $t1, -1 
repeat:
	addi $s1, $s1, 1
	j loop
exit:
	#Exit
	addi $v0,$0,10
	syscall
## KET THUC THAO TAC 6. ##

TestIntDMY:	
	la $a0,sTIME1
	
	jal intDay
	add $a0,$v0,$0
	addi $v0,$0,1
	syscall
	
	la $a0,sTIME1
	jal intMonth
	add $a0,$v0,$0
	addi $v0,$0,1
	syscall
	
	la $a0,sTIME1
	jal intYear
	add $a0,$v0,$0
	addi $v0,$0,1
	syscall
	
	la $a0,snewline
	addi $v0,$0,4
	syscall
	
##  HAM CHUYEN DOI TU KY SO SANG SO - KHONG DUNG STACK  ##
aton:
	add $v0,$0,$0
	add $v1,$0,$0	#v1 = 1 thi chuoi nhap vao co ky tu
	add $t0,$a0,$0  #bien tam de luu DIA CHI ky tu dang xet
loopaton:
	addi $t2,$0,10
	lb $t1,0($t0)	#$t1 chua ki tu dang xet
	beq $t1,$0,exitaton #Neu la ky tu ket thuc chuoi thi thoat, tra ve
	beq $t1,$t2,exitaton #Neu la ky tu xuong dong (13) thi cung thoat
	addi $t2,$t1,-48 #Ky tu - 48 = So (luc nay da dung xong t1)
	
	#Kiem tra so co phai trong doan [0,9] hay khong
	slt $t1,$t2,$0
	bne $t1,$0,falseinput
	addi $t1,$0,9
	slt $t1,$t1,$t2
	bne $t1,$0,falseinput
	
	#Neu so hop le, tang v0
	addi $t1,$0,10	#So 10
	mult $v0,$t1	#Nhan v0 cho 10
	mflo $v0
	add $v0,$v0,$t2	#v0 = v0 + t2
	
	addi $t0,$t0,1
	j loopaton
falseinput:
	addi $v1,$0,1	
exitaton:
	jr $ra
	

##  KIEM TRA 1 SO CO PHAI NAM NHUAN KHONG - KHONG DUNG STACK  ##	
leapYear:
	add $v0,$0,$0
	addi $t0,$0,4
	div $a0,$t0
	mfhi $t0
	bne $t0,$0,notleap	#x % 4 != 0
	
	addi $t0,$0,100
	div $a0,$t0
	mfhi $t0
	bne $t0,$0,leap		#x % 4 == 0 && x % 100 != 0
	addi $t0,$0,400
	div $a0,$t0
	mfhi $t0
	bne $t0,$0,notleap 	#x%100 == 0 but x%400!=0
leap:
	addi $v0,$v0,1
notleap:
	jr $ra
	
##  KIEM TRA CHUOI CHAR CO PHAI LA NGAY TRONG NAM NHUAN KHONG - CO STACK  ##
charLeapYear:
	#Store $ra
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	addi $a0,$a0,6	#$a0 -> yyyy
	
	jal aton
	add $a0,$v0,$0
	jal leapYear
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
##  char* Date(int day, int month, int year, char* TIME)  ##
##  CHUYEN DOI TU STRUCT SANG CHAR*  ##
charDate:
	#Chuyen doi va chen DAY vao chuoi
	addi $t0,$0,10
	div $a0,$t0
	mflo $t1
	addi $t1,$t1,48
	sb $t1,0($a3)
	mfhi $t1
	addi $t1,$t1,48
	sb $t1,1($a3)
	
	addi $t1,$0,'/'
	sb $t1,2($a3)
	
	#Chuyen doi va chen MONTH vao chuoi
	addi $t0,$0,10
	div $a1,$t0
	mflo $t1
	addi $t1,$t1,48
	sb $t1,3($a3)
	mfhi $t1
	addi $t1,$t1,48
	sb $t1,4($a3)
	
	addi $t1,$0,'/'
	sb $t1,5($a3)
	
	#Chuyen doi va chen YEAR
	addi $t0,$0,1000 #Lay chu so hang ngan
	div $a2,$t0
	mflo $t1
	addi $t1,$t1,48
	sb $t1,6($a3)
	mfhi $a2
	
	addi $t0,$0,100 #Lay chu so hang tram
	div $a2,$t0
	mflo $t1
	addi $t1,$t1,48
	sb $t1,7($a3)
	mfhi $a2
	
	addi $t0,$0,10	#Lay chu so hang chuc va don vi
	div $a2,$t0
	mflo $t1
	addi $t1,$t1,48
	sb $t1,8($a3)
	mfhi $t1
	addi $t1,$t1,48
	sb $t1,9($a3)
	
	addi $t0,$0,0	#Chen vao \0
	sb $t0,10($a3)
	
	add $v0,$a3,$0	#Ham tra ve dia chi chuoi TIME
	jr $ra

##  int Day(char*)   ##
##  char* co dang DD/MM/YYYY  ##
intDay:
	addi $t1,$0,10
	
	#Tach lay hang chuc	
	lb $t0,0($a0)
	addi $t0,$t0,-48
	
	#Chu so hang chuc nhan 10, dua vao ket qua
	mult $t0,$t1
	mflo $v0
	
	#Tach lay hang don vi
	lb $t0,1($a0)
	addi $t0,$t0,-48
	
	add $v0,$v0,$t0
	jr $ra
	
##  int Month(char*)   ##
##  char* co dang DD/MM/YYYY  ##
intMonth:
	addi $t1,$0,10
	
	#Tach lay hang chuc	
	lb $t0,3($a0)
	addi $t0,$t0,-48
	
	#Chu so hang chuc nhan 10, dua vao ket qua
	mult $t0,$t1
	mflo $v0
	
	#Tach lay hang don vi
	lb $t0,4($a0)
	addi $t0,$t0,-48
	
	add $v0,$v0,$t0
	jr $ra
	
##  int Year(char*)  ##
##  char* co dang DD/MM/YYYY  ##
intYear:
		
	#Tach hang ngan
	addi $t1,$0,1000
	lb $t0,6($a0)
	addi $t0,$t0,-48
	
	mult $t0,$t1
	mflo $v0
	
	#Tach hang tram
	addi $t1,$0,100
	lb $t0,7($a0)
	addi $t0,$t0,-48
	
	mult $t0,$t1
	mflo $t1
	
	add $v0,$v0,$t1
	
	#Tach hang chuc
	addi $t1,$0,10
	lb $t0,8($a0)
	addi $t0,$t0,-48
	
	mult $t0,$t1
	mflo $t1
	
	add $v0,$v0,$t1
	
	#Tach hang don vi
	lb $t0,9($a0)
	addi $t0,$t0,-48
	
	add $v0,$v0,$t0
	jr $ra
	
	
##  char* Convert(char* TIME, char type)  ##
##  CHUYEN TU DD/MM/YYYY SANG CAC KIEU KHAC  ##
##  A: MM/DD/YYYY  ##
##  B: MONTH DD, YYYY  ##
##  C: DD MONTH, YYYY  ##
charConvert:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	#Lay nam, luu vao stack (dang ky tu)	
	addi $sp,$sp,-4
	lb $t0,6($a0)
	sb $t0,0($sp)
	lb $t0,7($a0)
	sb $t0,1($sp)
	lb $t0,8($a0)
	sb $t0,2($sp)
	lb $t0,9($a0)
	sb $t0,3($sp)	
	
	#Lay ngay, luu vao stack (dang ky tu)	
	addi $sp,$sp,-2
	lb $t0,0($a0)
	sb $t0,0($sp)
	lb $t0,1($a0)
	sb $t0,1($sp)	
		
		
	#Lay thang (dang so nguyen) luu vao t1
	jal intMonth
	add $t1,$v0,$0	
	
	
	#Kiem tra muon chuyen ve dang nao, neu khac ABC la khong chuyen
	addi $t3,$0,'A'
	beq $a1,$t3,convertTypeA
	addi $t3,$0,'B'
	beq $a1,$t3,convertTypeB
	addi $t3,$0,'C'
	beq $a1,$t3,convertTypeC
	
	#Neu khong chuyen thi tra ve $a0 khong thay doi gi
	#Neu khong chuyen thi pop stack ra bot
	addi $sp,$sp,6
convertReturn:	
	lw $ra,0($sp)	#Lay lai $ra
	addi $sp,$sp,4
	
	add $v0,$a0,$0
	jr $ra
convertTypeA:
	#Neu la loai A thi chi can doi cho ngay va thang, khong can dung t0 t1 t2
	lb $t0,0($a0)
	lb $t1,3($a0)
	sb $t0,3($a0)
	sb $t1,0($a0)
	
	lb $t0,1($a0)
	lb $t1,4($a0)
	sb $t0,4($a0)
	sb $t1,1($a0)
	addi $sp,$sp,6
	j convertReturn
convertTypeB:
	#Loai B thi tu thang suy ra chuoi ky tu can in
	addi $t1,$t1,-1	#Thang 1 thi tuong ung voi phan tu [0]
	
	#La khoang cach tinh bang byte tu phan tu dau tien toi phan tu thu t1 (moi phan tu 4 byte - vi dang lam viec tren mang sizeMonth)
	sll $t3,$t1,2
	la $t4,sizeMonth
	la $t5,sMonths
	
	add $t4,$t4,$t3	#t4 gio se tro vao dung phan tu thu t1
	lw $t3,0($t4)	
	#t3 gio se la khoang cach toi bit dau cua chuoi ten thang hien tai. 
	#VD: Thang 8 thi t3 la khoang cach tu bit 0 -> bit chua chu 'A' trong 'August'
	
	add $t5,$t5,$t3	#t5 tro den dung chuoi can chep
	add $t4,$a0,$0	#t4 dung de lam con tro, thay doi phan tu trong chuoi TIME
loopGetStringMonthB:
	lb $t3,0($t5)	#Lay ky tu trong chuoi can chep
	beq $t3,$0,endLoopGetStringB	#Gap '\0' thi thoat lap
	sb $t3,0($t4)
	addi $t4,$t4,1
	addi $t5,$t5,1
	j loopGetStringMonthB
endLoopGetStringB:
	#Them cac thanh phan khac
	#Them dau cach
	addi $t3,$0,' '
	sb $t3,0($t4)
	addi $t4,$t4,1
	
	#Lay ngay ra tu stack
	lb $t2, 0($sp)	
	sb $t2, 0($t4)
	lb $t2, 1($sp)
	sb $t2, 1($t4)
	addi $sp,$sp,2
	addi $t4,$t4,2
	
	#Them dau phay
	addi $t3,$0,','
	sb $t3,0($t4)
	addi $t4,$t4,1

	#Them dau cach
	addi $t3,$0,' '
	sb $t3,0($t4)
	addi $t4,$t4,1		
	
	#Lay nam ra tu stack
	lb $t2,0($sp)	
	sb $t2,0($t4)
	lb $t2,1($sp)	
	sb $t2,1($t4)
	lb $t2,2($sp)	
	sb $t2,2($t4)
	lb $t2,3($sp)	
	sb $t2,3($t4)
	addi $sp,$sp,4
	addi $t4,$t4,4
	
	#Them ky tu '\0'
	sb $0,0($t4)
	#Xu ly xong chuoi, return
	j convertReturn

convertTypeC:
	#Loai C thi tu thang suy ra chuoi ky tu can in
	addi $t1,$t1,-1	#Thang 1 thi tuong ung voi phan tu [0]
	
	#La khoang cach tinh bang byte tu phan tu dau tien toi phan tu thu t1 (moi phan tu 4 byte - vi dang lam viec tren mang sizeMonth)
	sll $t3,$t1,2
	la $t4,sizeMonth
	la $t5,sMonths
	
	add $t4,$t4,$t3	#t4 gio se tro vao dung phan tu thu t1
	lw $t3,0($t4)	#Doc phan tu thu t1 cua mang chua do dai chuoi dua vao t3
	#t3 gio se la khoang cach toi bit dau cua chuoi ten thang hien tai. 
	#VD: Thang 8 thi t3 la khoang cach tu bit 0 -> bit chua chu 'A' trong 'August'
	
	add $t5,$t5,$t3	#t5 tro den dung chuoi can chep
	add $t4,$a0,$0	#t4 dung de lam con tro, thay doi phan tu trong chuoi TIME
	
	#Lay ngay ra tu stack
	lb $t2, 0($sp)
	sb $t2, 0($t4)
	lb $t2, 1($sp)
	sb $t2, 1($sp)
	addi $sp,$sp,2
	addi $t4,$t4,2
	
	#Them dau cach
	addi $t3,$0,' '
	sb $t3,0($t4)
	addi $t4,$t4,1
	
loopGetStringMonthC:
	lb $t3,0($t5)	#Lay ky tu trong chuoi can chep
	beq $t3,$0,endLoopGetStringC	#Gap '\0' thi thoat lap
	sb $t3,0($t4)
	addi $t4,$t4,1
	addi $t5,$t5,1
	j loopGetStringMonthC
endLoopGetStringC:
	#Them cac thanh phan khac	
	#Them dau phay
	addi $t3,$0,','
	sb $t3,0($t4)
	addi $t4,$t4,1
	
	#Them dau cach
	addi $t3,$0,' '
	sb $t3,0($t4)
	addi $t4,$t4,1
		
	#Lay nam ra tu stack
	lb $t2,0($sp)	
	sb $t2,0($t4)
	lb $t2,1($sp)	
	sb $t2,1($t4)
	lb $t2,2($sp)	
	sb $t2,2($t4)
	lb $t2,3($sp)	
	sb $t2,3($t4)
	addi $sp,$sp,4
	addi $t4,$t4,4
	
	#Them ky tu '\0'
	sb $0,0($t4)
	#Xu ly xong chuoi, return
	j convertReturn

	
GetTime:
	addi $sp,$sp,-4
	sw $ra, 0($sp)
	
	#lay ngay cua char 1
	jal intDay
	add $t0,$zero,$v0 # ngay cua char 1
	
	#luu lai nhung t co the bi mat khi truyen ham
	addi $sp,$sp,-24
	sw $t0,0($sp)
	
	#lay thang cua char 1
	jal intMonth
	add $t1,$zero,$v0 # thang cua char 1
	sw $t1,4($sp)
	
	#lay nam cua char 1
	jal intYear
	add $t2,$zero,$v0 # nam cua char 1
	sw $t2, 8($sp)
	
	
	
	#thao tac voi char 2
	add $a0,$zero,$a1
	#lay ngay cua char 2	
	jal intDay
	add $t3,$zero,$v0 # ngay cua char 2
	sw $t3, 12($sp)
	
	#lay thang cua char 2
	jal intMonth
	add $t4,$zero,$v0 # thang cua char 2
	sw $t4, 16($sp)
	
	#lay nam cua char 2
	jal intYear
	add $t5,$zero,$v0 # nam cua char 2
	sw $t5,20($sp)
	
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $t2,8($sp)

	
	
	add $a0,$zero,$t0
	add $a1,$zero,$t1
	add $a2,$zero,$t2
	jal countDaytoNow
	add $t6,$v0,$zero #khoang cach cua ngay 1
	
	lw $t3,12($sp)
	lw $t4,16($sp)
	lw $t5,20($sp)
	addi $sp,$sp,24
	
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$t5
	jal countDaytoNow
	add $t7,$v0,$zero #khoang cach cua ngay 2
	
	
	slt $t0,$t6,$t7
	beq $t0,$zero,smaller
	sub $t0,$t7,$t6
	j bigger
	smaller:
		sub $t0,$t6,$t7	
	bigger:
		
	add $v0,$t0,$zero
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
isDayOfWeek:

	add $t0,$a0,$zero
	addi $t1,$zero,7
	div $t0,$t1
	mfhi $t1 # tim ra so du, 0:CN, 1: Mon ,..
	
	addi $t2,$t1,1 #luu chieu dai tiep theo cua mang thu
	sll $t1,$t1,2
	sll $t2,$t2,2
	
	lw $t1,sizeWeek($t1) # lay mang ra tu sizeWeek
	lw $t2,sizeWeek($t2)
 
	la $t3,ArrDayOfWeek
	add $t4,$zero,$zero #vi tri cua chuoi dang them vao
 
	loopIsDayOfWeek:
		beq $t1,$t2,endLoopIsDayOfWeek
 
		add $t5,$t3,$t1 # vi tri cua mang ArrDayOfWeek
		
		lb $t6,0($t5)
		sb $t6,DayOfWeek($t4) # gan tung ki tu vao mang can tra ve
 
		addi $t4,$t4,1
		addi $t1,$t1,1
		
 		j loopIsDayOfWeek
	endLoopIsDayOfWeek:
	
	la $v0,DayOfWeek
	jr $ra
	
#tinh so ngay cua nam, nhuan thi 366, khong nhuan thi 365
countDayInYear:
	
	#luu lai dia chi $ra
	addi $sp,$sp,-4# co the bug o day
	sw $ra, 0($sp)
	
	jal leapYear 
	
	#neu la nam  khong nhuan thi 365, nhuan thi 366 
	add $t0,$v0,$zero
	addi $t1,$zero,365 #t1 la gia tri tra ve 
	beq $t0,$zero,endOfCountDayInYear
	addi $t1,$t1,1
	endOfCountDayInYear:
	
	add $v0,$t1,$zero
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
#tinh so ngay tu  nam 1900 den truoc nam duoc truyen vao 
countDayBeforeYear: #tinh den nam hien tai
	addi $sp,$sp,-4 # co the bug o day
	sw $ra,0($sp)
	
	
	add $t0,$zero,$zero # bien dem
	add $t1,$zero,$a0 #  n = so nam luu vao t1 
	addi $t2,$zero,1900
	LoopCountDayBeforeYear:
	
		beq $t2,$t1, endCountDayBeforeYear# while i!=n
		add $a0,$zero,$t2
		
		addi $sp,$sp -12
		sw $t0,0($sp)
		sw $t1,4($sp)
		sw $t2,8($sp)
		
		jal countDayInYear # so ngay cua nam do
		
		lw $t0,0($sp)
		lw $t1,4($sp)
		lw $t2,8($sp)
		addi $sp,$sp,12 
		
		
		add $t0,$t0,$v0 # sum=sum + v0
		addi $t2,$t2,1 # i++
		j LoopCountDayBeforeYear
	endCountDayBeforeYear:
	
	
	add $v0,$zero,$t0
	lw $ra, 0($sp)
	addi $sp,$sp,4
	jr $ra
#tinh so ngay cua thang	 tuong ung
countDayOfMonth:

	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	add $t0,$a1,$zero # nam
	add $t1,$a0,$zero #thang
	
	addi $sp,$sp,-8
	sw $t0,0($sp)
	sw $t1,4($sp)
	
	add $a0,$zero,$t0
	jal leapYear
	
	lw $t0,0($sp)
	lw $t1,4($sp)
	addi $sp,$sp,8
	
	add $t5,$zero,$v0 # 1 la nam nhuan, 0 la nam khong nhuan
	addi $t4,$zero,2 # dung de so sanh voi thang 2
			
	addi $t2,$t1,-1  # thang - 1 do mang luu ngay bat dau tu 0
	lb $t3, dayOfMonth($t2)
	
	bne $t1,$t4,notFebAndLeap #xet co phai la thang 2 ko
	beq $t5,$zero,notFebAndLeap
	
	addi $t3,$t3,1 #neu la nam nhuan va thang 2 thi cong 1
	
	notFebAndLeap:
	add $v0,$t3,$zero
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
	
#tinh so ngay truoc thang nguoi dung nhap
countDayBeforeMonth:
	addi $sp,$sp,-4
	sw $ra, 0($sp)
	
	add $t0,$zero,$zero #sum
	add $t1,$a0,$zero #thang
	add $t2,$a1,$zero # nam
	addi $t3,$zero,1 #bien chay i=1
	
	loopCountDayBeforeMonth:
		beq $t3,$t1,endLoopCountDayBeforeMonth # neu i==n thi dung 
		
		
		addi $sp,$sp -16
		sw $t0,0($sp)
		sw $t1,4($sp)
		sw $t2,8($sp)
		sw $t3,12($sp)
		
		add $a0,$t3,$zero
		add $a1,$t2,$zero
		jal countDayOfMonth
	
		lw $t0,0($sp)
		lw $t1,4($sp)
		lw $t2,8($sp)
		lw $t3,12($sp)
		addi $sp,$sp,16
		
		add $t0,$t0,$v0
		addi $t3,$t3,1
		j loopCountDayBeforeMonth
	endLoopCountDayBeforeMonth:
	
	lw $ra, 0($sp)
	add $v0,$zero,$t0 # return 
	addi $sp,$sp,4
	jr $ra
	

countDaytoNow: #tinh den thang hien tai tu nam 1900
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	add $t0,$zero,$zero
	
	addi $sp,$sp -16
	sw $a0,0($sp) # ngay
	sw $a1,4($sp) #thang
	sw $a2,8($sp) #nam
	sw $t0,12($sp) 

	add $a0,$a2,$zero
	jal countDayBeforeYear #dem so ngay truoc nam hien tai
	
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $t0,12($sp) 
	addi $sp,$sp,16
	
	add $t0,$t0,$v0  # cong vao sum
	
	addi $sp,$sp -16
	sw $a0,0($sp) # ngay
	sw $a1,4($sp) #thang
	sw $a2,8($sp) #nam
	sw $t0,12($sp) 

	add $a0,$a1,$zero
	add $a1,$a2,$zero
	jal countDayBeforeMonth #dem so ngay truoc nam hien taitai
	
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $t0,12($sp) 
	addi $sp,$sp,16
	

	add $t0,$t0,$v0 #cong so thang trong nam vao sum
	 
	add $t0,$t0,$a0 #cong ngay vao sum
	#addi $t0,$t0,  # tinh ngay bat dau tu 1 chu khong phai tu 0
	
	#addi $t5,$zero,7
	#div $t0,$t5
	#mfhi $t6
	
	add $v0,$t0,$zero
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra


charDayOfWeek:
	addi $sp,$sp,-8
	sw $ra,0($sp)	
	sw $a0,4($sp)
	
	jal intYear	
	add $a2,$v0,$0
	
	jal intMonth
	add $a1,$v0,$0
	
	jal intDay
	add $a0,$v0,$0
	
	jal countDaytoNow
	add $a0,$v0,$0
	
	jal isDayOfWeek
	lw $a0,4($sp)
	lw $ra,0($sp)
	addi $sp,$sp,8
	
	jr $ra
