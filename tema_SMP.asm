;Otesanu Madalina, grupa 333AA
;    
; - Jocul incepe prin afisarea mesajului "TheSnakeGame!",
; dupa care acesta dispare de pe ecran si se deseneaza
; peretii jocului;
; - Dupa ce peretii au fost desenati, apare sarpele avand
; initial marimea de o unitate si mancarea acestuia;
; - Sarpele  trebuie sa manance gustarile ce sunt generate aleator 
; in joc, urmand ca marimea acestuia sa creasca la
; fiecare gustare;
; - Daca sarpele atinge peretii jocului, atunci jocul
; se termina prin afisarea mesajului "Game Over" si
; a unui sunet specific.
; - Pentru navigare se utilizeaza:
;   sus :    0 
;   jos :    l
;   dreapta: p
;   stanga:  o
; Jocul se afla si pe github : https://github.com/madalinaotesanu/Tema-SMP


org 100h

;definire assembley - macros;
random macro range
       mov ah,00h
       int 1Ah
       mov ax,dx
       xor dx,dx
       mov bx, range
       div bx
       inc dx   
endm


Meniu:
call Stergere
call Pagina_inceput


Incep_joc:
call Stergere
call Setare_joc  

Pasul_initial:
call Repaus
call Mutare_snake
pop ax
cmp ax,1
je Meniu
call Verific_schimd
jmp Pasul_initial

hlt


;pagina de pornire a jocului
proc Pagina_inceput
    call Stergere_ecran
    Mesaj_inceput:
    mov bh,0
    mov ah,13h
    mov al,0
    mov dh,1
    mov dl,09
    mov bl,3;culoare mesaj de inceput
    mov cx,52d
    mov bp,offset Linia_1 
    int 10h 
    inc dh
    mov bp,offset Linia_2 
    int 10h
    inc dh
    mov bp,offset Linia_3 
    int 10h
    inc dh
    mov bp,offset Linia_4 
    int 10h 
    inc dh
    mov bp,offset Linia_5 
    int 10h
    inc dh
    mov bp,offset Linia_6 
    int 10h
    inc dh
    mov bp,offset Linia_7 
    int 10h
    inc dh
    mov bp,offset Linia_8 
    int 10h
    inc dh
    mov bp,offset Linia_9 
    int 10h
    inc dh
    mov bp,offset Linia_10 
    int 10h
    inc dh
    mov bp,offset Linia_11 
    int 10h
           
    mov cx,1
    astept2: 
    call Repaus
    loop astept2


    ret
endp Pagina_inceput


;pornirea jocului prin setare
proc Setare_joc
    call Stergere_ecran
    mov dl,0 ;pozitionare cursor la (0,0)
    mov dh,0
    
	
    Desenare_perete:  ;jocul porneste prin desenarea peretilor
    
;Deseneaza peretele de sus
    Perete_sus:
    mov bh, 0
    mov ah, 0x2
    int 0x10 ;set mod  
    mov dl,0
    mov dh,0  
    mov cx, 80;
    mov bh, 0
    mov bl, 200;culoare perete
    mov al, ' '
    mov ah, 0x9
    int 0x10
 
; Deseneaza peretele din stanga
    Perete_stanga:   
    inc dh
    mov cl,' '
    mov ch, 200 ;culoare perete
    push dx
    push cx
    push dx
    call SetPoint
    pop dx
    cmp dh,25d               
    jne Perete_stanga 
    mov dl,79
    mov dh,0

;Deseneaza peretele din dreapta	
    Perete_dreapta: 
    inc dh
    mov cl,' '
    mov ch,200 ;culoare perete
    push dx
    push cx
    push dx
    call SetPoint
    pop dx
    cmp dh,25d
    jne Perete_dreapta
    
     
;Deseneaza peretele de jos    
    Perete_jos: 
    mov bh, 0
    mov ah, 0x2
    int 0x10    
    mov dl,0
    mov dh,24
    mov ah, 0x2
    int 0x10
    mov cx, 80
    mov bh, 0
    mov bl, 200 ; culoare perete
    mov al, ' '
    mov ah, 0x9
    int 0x10
    
	
;Pozitionarea sarpelui      
    mov cl,Tip_sarpe
    mov ch,Cul_sarpe
    push cx    
    mov dh,cap_y
    mov dl,cap_x  
    push dx
    call SetPoint
    
    ;coordonatele pentru noua mancare
    call Mancare_noua
     
    ret
endp Setare_joc

;golirea ecranului de animatii
proc Stergere_ecran
Stergere_camp:
    mov dl,0 ;pozitionare cursor la (0,0)
    mov dh,0  
    sterg_consola:
    mov bh, 0
    mov ah, 0x2
    int 0x10
    mov cx, 80 ; printare caracter
    mov bh, 0
    mov bl, 00d 
    mov al, 0   ;caracter negru 
    mov ah, 0x9
    int 0x10
    inc dh
    cmp dh,25d
    jne sterg_consola
    ret
    
endp Stergere_ecran



proc SetPoint
    ; Inainte de a pozitiona mancarea se iau parametrii
	; ce caracterizeaza mancarea forma(tip) si culoarea
    pop [150]
    pop dx;locatie dh = y; dl = x
    
    pop cx ;cl forma, ch culoare
    mov al,dh
    mov bl,80d
    mul bl
    add ax,ax
    add dl,dl
    mov dh,0
    add ax,dx
    mov bx,ax        
    push ds 
    mov ax, 0b800h
    mov ds,ax
    ;mov bx,1
    mov [bx],cx 
    pop ds
    push [150]
    ret
endp SetPoint

proc Repaus
    pusha
    mov cx, 02h
    mov dx, 4240h
    mov ah, 86h
    int 15h
    popa
    ret
endp Repaus


proc GetPoint
;Returneaza sirul in anumite zone din stive dupa care forma si culoarea
    pop [150]
    pop dx;locatie dl = x; dh = y
    push [150]  
    mov al,dh
    mov bl,80d
    mul bl
    add ax,ax
    add dl,dl
    mov dh,0
    add ax,dx
    mov bx,ax
    push ds
    mov ax, 0b800h
    mov ds,ax
    ;mov bx,1
    mov cx,[bx] 
    pop ds
    pop [150]
    push cx
    push [150] 
 
    ret
endp GetPoint


;realizeaza mutarea sarpelui in joc
proc Verific_schimd 
	mov ah,1h ;verifica daca orice tasta a fost apasata 
    int 16h
    jnz Preia_mutarea;se apasa pe orice tasta de navigare
    jmp Fara_mutare  ;nicio tasta nu a fost apasata
  
    Preia_mutarea:
    mov ah,0h;preia tasta apasata
    int 16h
    
    ;tastele pentru navigare
    cmp al, '0' ;sus
    je Mutare_sus  
    cmp al, 'o' ;stanga
    je Mutare_stanga
    cmp al, 'p' ;dreapta
    je Mutare_dreapta
    cmp al, 'l' ;jos
    je Mutare_jos
    cmp al,20h
    jne Fara_mutare
    pop dx
    jmp Meniu
    
    Mutare_sus:
    cmp cap_d,1
    je Fara_mutare
    mov cap_d,1
    
    jmp Schimb_directie
    
    Mutare_dreapta:
    cmp cap_d,2
    je Fara_mutare
    mov cap_d,2

    
    jmp Schimb_directie
          
    Mutare_jos:
    cmp cap_d,3
    je Fara_mutare
    mov cap_d,3
    
  
    jmp Schimb_directie
    
    Mutare_stanga:
    cmp cap_d,4
    je Fara_mutare
    mov cap_d,4
    
;se realizeaza schimbarile de directie    
    Schimb_directie:
    mov si,[l_schimb]
    mov al,cap_d
    mov Intoarcere[si],al
    add si,si
    mov al,cap_x
    mov ah,cap_y
    mov pozitie[si],ax
    inc l_schimb
	
    Fara_mutare: 
    ret
    
endp Verific_schimd 

  
;mutare sarpe dupa ce mananca 
proc Mutare_snake
    
    cmp Mananca_sarpele,1;verifica daca sarpele mananca
    je salt
           
    cmp l_schimb,0
    je Modif_coada
    mov si,0   ;intoarcerea curenta
    mov ax,pozitie[si]
    cmp coada_x,al
    jne Modif_coada
    cmp coada_y,ah
    jne Modif_coada
    
     
    Schimba_coada_d:
    ;sus 
    mov al,Intoarcere[si]
    mov coada_d,al
    
    Modif_intorc:
    mov si,0
    cmp l_schimb,1
    ja contin 
    
    mov Intoarcere[si],00h
    mov pozitie[si],0000h
    dec l_schimb
    jmp Modif_coada
    
    contin:
    mov cx,l_schimb
    dec cx 
    Sort_poz:
    mov ax,pozitie[si+2]
    mov pozitie[si],ax
    add si,2
    loop Sort_poz
    
    mov si,0
    mov cx,l_schimb
    dec cx 
    Sort_int:
    mov al,Intoarcere[si+1]
    mov Intoarcere[si],al
    inc si
    loop Sort_int
    
    dec l_schimb 
    
	
    Modif_coada: 
    mov cl,0
    mov ch,0
    push cx
    
    mov dh,coada_y
    mov dl,coada_x 
    push dx
    call SetPoint
    
    mov Mananca_sarpele,0
    
    cmp coada_d,1
    je coada_sus
    cmp coada_d,2
    je coada_dreapta
    cmp coada_d,3
    je coada_jos
    cmp coada_d,4
    je coada_stanga
    
    
    coada_sus:
    dec coada_y
    jmp salt 
    coada_dreapta:
    inc coada_x
    jmp salt
    coada_jos:
    inc coada_y
    jmp salt
    coada_stanga:
    dec coada_x
    
    salt:
    cmp Mananca_sarpele,1
    je marire_sarpe
    jmp urmeaza
    
    
    marire_sarpe:
    mov Mananca_sarpele,0
    inc Marime_sarpe
    
    urmeaza:

    cmp cap_d,1
    je sus
    
    cmp cap_d,2
    je dreapta
    
    cmp cap_d,3
    je jos
    
    cmp cap_d,4
    je stanga 
    
    
    
    sus:
    dec cap_y
    jmp muta 
    dreapta:
    inc cap_x
    jmp muta
    jos:
    inc cap_y
    jmp muta
    stanga:
    dec cap_x
    
    
    muta:
    
 ;Verifica daca sarpele mananca
    call Sarpe_m
    
 ;Verifica daca jocul a fost pierdut
    call Verific_pierd
    pop ax
    cmp ax,1
    je Joc_pierdut
    mov cl,Tip_sarpe
    mov ch,Cul_sarpe
    push cx
    
    mov dh,cap_y
    mov dl,cap_x 
    push dx
    call SetPoint
    jmp PointDone
    Joc_pierdut:
    call Sfarsit_joc
    pop [150]
    push 1
    push [150] 
    ret
    
    PointDone:
    pop [150]
    push 0
    push [150]
    ret
endp Mutare_snake


proc Sarpe_m
    xor ax,ax
    
    mov dh,cap_y
    mov dl,cap_x
              
    push dx
    call GetPoint
    pop cx
    cmp cl,t_m1
    je m1
    cmp cl,t_m2
    je m2
    cmp cl,t_m3
    je m3
    jmp none

;mancarea m1    
    m1:
    mov al,v_m1
    add Points,ax
    jmp a_mancat

;mancarea m2	
	m2:
    mov al,v_m2
    add Points,ax
    jmp a_mancat    
    
;mancarea m3            
    m3:
    mov al,v_m3
    add Points,ax
	
; ce a mancat sarpele     
    a_mancat:
    mov Mananca_sarpele,1  
    call Mancare_noua
    none:
    
    
    ret
endp Sarpe_m

; Functia Mancare_noua genereaza in joc pozitii random cu mancare
proc Mancare_noua
    afla_y: 
    random camp_y
    mov temp_y,dl
    cmp temp_y,0
    je afla_y
    cmp temp_y,24d
    jae afla_y
    afla_x:
    random camp_x
    mov temp_x,dl
    cmp temp_x,80d
    je afla_x
 
;generare pozitie random pt mancare 
    random 3d
    cmp dl,1
    je locatie_m1
    cmp dl,2
    je locatie_m2
    cmp dl,3
    je locatie_m3
	
;locatie mancare m1    
    locatie_m1:
    mov ch,c_m1
    mov cl,t_m1
    jmp locatie
    
;locatie mancare m2	
    locatie_m2:
    mov ch,c_m2
    mov cl,t_m2
    jmp locatie 

;locatie mancare m3    
    locatie_m3:
    mov ch,c_m3
    mov cl,t_m3

;locatia in coord temp:	
    locatie:
    mov dh,temp_y
    mov dl,temp_x
    
    
    push cx; forma,culoare
    push dx; coodonatele (x,y)
    call SetPoint
    
    
    ret
endp

;se verifica daca se pierde jocul
proc Verific_pierd
    
    mov dh,cap_y
    mov dl,cap_x
              
    push dx
    call GetPoint
    pop cx
    cmp cl,20h
    je Pierdut
    cmp cl,2ah
    je Pierdut
    jmp Continua
 
    Pierdut:
    pop [150]
    push 1
    push [150]
    ret
    Continua:
    pop [150]
    push 0
    push [150]
    ret
endp Verific_pierd

;afiseaza un mesajul "Game Over", alaturi de un sunet beep
proc Sfarsit_joc
    mov bh,0
    mov ah,13h
    mov al,0
    mov dh,10
    mov dl,10 
    mov bl,3
    mov cx,50d
    mov bp,offset Liniaf_1 
    int 10h 
    inc dh
    mov bp,offset Liniaf_2 
    int 10h
    inc dh
    mov bp,offset Liniaf_3 
    int 10h
    inc dh
    mov bp,offset Liniaf_4 
    int 10h
             
  mov cx,5
    waitsec: 
    call Repaus
    loop waitsec
                        
    call Sunet
    
    ret
endp Sfarsit_joc   


;Functia Sunet este folosita pentru a marca sfarsitul jocului
proc Sunet
mov ah, 02
mov dl, 07h ;07h este valoarea care produce sunetul beep
int 21h ;produce efectiv sunetul
int 20h
endp Sunet



;stergerea tuturor registrilor
proc Stergere
    xor ax,ax
    xor bx,bx
    xor dx,dx
    xor cx,cx
    mov cap_x,1
    mov cap_y,1
    mov coada_x,1
    mov coada_y,1
    mov cap_d,2
    mov coada_d,2
    mov Points,0d 
    mov Marime_sarpe,1
    mov cx,l_schimb
    add cx,cx
    cmp cx,0
    je noneValues 
    resetare_sir:
    mov si,cx
    mov Intoarcere[si],0         
    loop resetare_sir;
    mov l_schimb,0                   
    noneValues:
    
    ret 
endp Stergere

ret

;coordonate pentru cap si coada (x,y)
cap_x db 1  
cap_y db 1
coada_x db 1
coada_y db 1
cap_d db 2
coada_d db 2

Intoarcere db 2000 dup(?)
pozitie dw 2000 dup(?)
l_schimb dw 0

Marime_sarpe db 1
Mananca_sarpele db 0
                
              
 
 
;Valori 
Points dw 0d

;Meniu
OptionsPosition db 1



;proprietati sarpe
Cul_sarpe db 233
Tip_sarpe db ' '


;valori mancare
v_m1 db 10d ;*
v_m2 db 20d ;@
v_m3 db 30d ;#

;tipuri mancare
t_m1 db 0ebh
t_m2 db '@'
t_m3 db '#'

;culori mancare
c_m1 db 05h
c_m2 db 09h
c_m3 db 07h



;mancare locatie temp:
temp_y db ?
temp_x db ?

;dimensiuni campuri
camp_l dw 2000d; dimensiunea campului de lucru
camp_x dw 80d
camp_y dw 25d

 


;Mesajul de final de joc:
Liniaf_1 db "  ___   __   _  _  ____     __   _  _  ____  ____ " 
Liniaf_2 db " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \"
Liniaf_3 db "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /"
Liniaf_4 db " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)" 

;Mesajul de pe prima pagina
Linia_1 db  "  _______ _             _____             _         "
Linia_2 db  " |__   __| |           / ____|           | |        "
Linia_3 db  "    | |  | |__   ___  | (___  _ __   __ _| | _____  "
Linia_4 db  "    | |  | '_ \ / _ \  \___ \| '_ \ / _` | |/ / _ \ "
Linia_5 db  "    | |  | | | |  __/  ____) | | | | (_| |   <  __/ "
Linia_6 db  "   _|_|_ |_| |_|\___| |_____/|_| |_|\__,_|_|\_\___| "
Linia_7 db  "  / ____|                    | |                    "
Linia_8 db  " | |  __  __ _ _ __ ___   ___| |                    "
Linia_9 db  " | | |_ |/ _` | '_ ` _ \ / _ \ |                    "
Linia_10 db " | |__| | (_| | | | | | |  __/_|                    "
Linia_11 db "  \_____|\__,_|_| |_| |_|\___(_)                    "
T_Len equ $ - Linia_1

ret




