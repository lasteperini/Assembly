######################segmento dati#####################################


.data 

EN: .space 108 		# allocazione memoria lettere Inglese
IT: .space 108 		# allocazione memoria lettere Italiano
FR: .space 108 		# allocazione memoria lettere Francese
XX: .space 108 		# allocazione memoria lettere XX

frEN: .space 104 		# allocazione memoria frequenza lettere Inglese
frIT: .space 104 		# allocazione memoria frequenza lettere Italiano
frFR: .space 104 		# allocazione memoria frequenza lettere Francese
frXX: .space 104 		# allocazione memoria frequenza lettere XX

lettere: .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

fileToRead:  .space 30
filenameStat: "statistica.txt"

buffer: .asciiz ""
LF:	.asciiz "\n"

.align 2
bufferArrayVal: .word 0

endString: .asciiz " <--> "
spazio: .asciiz " "
acapo: .asciiz "\n"
incolonna: .asciiz "\t"


jatIniziale: .word default, memorizza, statistica, analizza, exit
jatMemorizzaLingua: .word defaultMemorizza, leggiEN, leggiIT, leggiFR, leggiXX, defaultMemorizza


inizio: .asciiz "Crittoanalisi Statistica: analizza una lingua e la sua frequenza dei caratteri\nRegistra nel database le lingue note (es: inglese.txt, italiano.txt, francese.txt) \ne il file che vuoi analizzare (es: testitaliano.txt)(opzione 1)\nCalcola le statistiche (opzione 2)\nDetermina la lingua del file test (opzione 3)\n"
menuIniziale: .asciiz "\nMenu':\n1-Inserisci in database un file\n2-Calcola statistiche\n3-Determina lingua sconosciuta\n4-Termina applicazione\n-->  "
menuLingua: .asciiz "\nScegli la lingua:\n1-Inglese\n2-Italiano\n3-Francese\n4-Lingua da analizzare\n5-Torna al menù iniziale-->  "
fineLetturaFile: .asciiz "\nFile letto correttamente\n"
str_scegli_file: .asciiz "Inserisci il path del file (Max 30 caratteri):"
analizzaPrompt: .asciiz "Inserisci la stringa da analizzare: "
totaleLetterePrompt: .asciiz "*** Numero totale di lettere analizzate: "
strLeggiInglese: .asciiz "\nLingua Inglese \n"
strLeggiItaliano: .asciiz "\nLingua Italiana \n"
strLeggiFrancese: .asciiz "\nLingua Francese \n"
strLeggiIgnota: .asciiz "\nLingua da determinare:\n"
readingMessage: .asciiz "\nReading............\n "
statNoAvailable: .asciiz "Nessuna statistica disponibile\n"
nessunaLingua: .asciiz "\nNessuna lingua identificata! Esegui prima il calcolo delle statistiche!"
strComparoInglese: .asciiz "\nComparo Inglese..."
strComparoItaliano: .asciiz "\nComparo Italiano..."
strComparoFrancese: .asciiz "\nComparo Francese..."
strStampaRisultato: .asciiz "\n\nLa lingua stimata è:"
percento: .asciiz " % "
sqrt: .asciiz "(sqrt) = "
maxChar: .asciiz "E' stato raggiunto il massimo numero di caratteri memorizzabili (2,147,483,647)"

opzioneNonValida: .asciiz "\nOpzione non valida!\n\n"
str_errore_file: .asciiz "\n\nErrore. File non trovato!\n\n"

#################################fine segmento dati########################


###########################################################################à
# propone un primo menu: 
#	memorizza una lingua
#	calcola e stampa le statistiche
#	riconosci una lingua
#	exit

.text
.globl main

main:	
	# scelte utente

	li $v0, 4				# print string
	la $a0, inizio			# stampa le opzioni possibili
	syscall
	
	j stampaMenuIniziale			# vai a menù iniziale
	
stampaMenuIniziale:				# MENU INIZIALE
									
	li $v0, 4				# print string
	la $a0, menuIniziale			# stampa le opzioni possibili
	syscall
	
	li $v0, 5				# read integer
	syscall							
	move $t0, $v0				# salva la scelta effettuata in $t0
	
	slt $t1, $zero, $t0			# controllo: se $t0 <= 0
	beq $t1, $zero, default			# va al caso default(operazione non valida)
	slti $t1, $t0, 5			# controllo: $t0 >= 5
	beq $t1, $zero, default			# va al caso default(operazione non valida)

			
	sll $t1, $t0, 2		
						# SCELTA PER MEZZO DELLA JUMP ADDRESS TABLE
	sll $t1, $t0, 2
	la $t0, jatIniziale
	add $t1, $t1, $t0
	lw $t1, 0($t1)
	jr $t1

		
default:
	li $v0, 4				# print string
	la $a0, opzioneNonValida		# se l'operazione scelta non è nel menù viene segnalato e riproposto il menù
	syscall 
	j stampaMenuIniziale			# torna al menù iniziale



memorizza:					# MEMORIZZA IL NUMERO DI CARATTERI IN UN FILE

	li $v0, 4				# print_string
	la $a0, str_scegli_file			# chiede il nome del file
	syscall
	
	li $v0, 8				# mette nel buffer fileToRead il file da leggere
	la $a0, fileToRead
   	li $a1, 30
    	syscall

	jal estrai_nome_file
	
	# faccio scegliere la lingua da analizzare
	li $v0, 4				# print string
	la $a0, menuLingua				
	syscall
	
	li $v0, 5				# read integer
	syscall							
	move $t0, $v0				# salva la scelta effettuata in $t0

	slt $t1, $zero, $t0			# controllo: se $t0 <= 0
	beq $t1, $zero, defaultMemorizza			# va al caso default(operazione non valida)
	slti $t1, $t0, 6			# controllo: $t0 >= 6
	beq $t1, $zero, defaultMemorizza			# va al caso default(operazione non valida)

			
						# SCELTA PER MEZZO DELLA JUMP ADDRESS TABLE
	sll $t1, $t0, 2
	
	la $t0, jatMemorizzaLingua
	add $t1, $t1, $t0
	lw $t1, 0($t1)
	jr $t1


leggiEN:
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiInglese				
	syscall

	la $a0, EN
	jal leggi_file
	j analizza_risultato_lettura

leggiIT:
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiItaliano				
	syscall

	la $a0, IT
	jal leggi_file
	j analizza_risultato_lettura
	
leggiFR:
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiFrancese				
	syscall

	la $a0, FR
	jal leggi_file				
	j analizza_risultato_lettura
	
leggiXX:
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiIgnota				
	syscall

	la $a0, XX
	jal azzera_array
	jal leggi_file
	j analizza_risultato_lettura

defaultMemorizza:
	li $v0, 4
	la $a0, opzioneNonValida		# se l'operazione scelta non è nel menù viene segnalato e riproposto il menù
	syscall 

	j stampaMenuIniziale			# torna al menù iniziale
	
analizza_risultato_lettura:	
	beq $v0, $zero, default			# $v0 restituisce 0 se il file non è stato trovato o se la scelta della lingua
						# non è stata effettuata correttamente ==> torna al default
	
	j stampaMenuIniziale			# torna al menù iniziale
	
statistica:
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiInglese				
	syscall

	la $a0, frEN
	la $a1, EN
	jal calcola_statistica
	la $a0, frEN
	la $a1, EN
	jal scrivi_statistica			# stampa le frequenze dei caratteri nelle varie lingue	

	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiItaliano				
	syscall

	
	la $a0, frIT
	la $a1, IT
	jal calcola_statistica
	la $a0, frIT
	la $a1, IT
	jal scrivi_statistica			# stampa le frequenze dei caratteri nelle varie lingue	

	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiFrancese				
	syscall

	la $a0, frFR
	la $a1, FR
	jal calcola_statistica
	la $a0, frFR
	la $a1, FR
	jal scrivi_statistica			# stampa le frequenze dei caratteri nelle varie lingue	

	li $v0, 4				# comando per la syscall di un print string
	la $a0, strLeggiIgnota				
	syscall

	la $a0, frXX
	la $a1, XX
	jal calcola_statistica
	la $a0, frXX
	la $a1, XX
	jal scrivi_statistica			# stampa le frequenze dei caratteri nelle varie lingue	


	j stampaMenuIniziale			# torna al menù iniziale

analizza:
	
	jal determina_lingua
	j stampaMenuIniziale			# torna al menù iniziale

exit:						# EXIT
	li $v0, 10
	syscall

	

#################################fine main   ##############################		
###########################################################################
#######------------------------PROCEDURE------------------------###########
################################# leggi file ##############################
# apre il file da leggere, controlla eventuali fallimenti:
# se il file non esiste
# se il numero di caratteri memorizzati supera il max integer
#
# parametri in ingresso
# $a0 array lingua
# valore del parametro in uscita ($v0): 
#	0 se fallisto 
#	1 se la lettura è andata a buon fine
# variabili usate da salvare nello stack:
# $s6 (file id)
# $s0 (salvataggio array in riempimento)


leggi_file:

	addi $sp, $sp, -16			# $sp -= 12
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)				# salvo $s0
	sw $s6, 8($sp)				# salvo $s6
	sw $fp, 12($sp)				# salvo $fp
	addi $fp, $sp, 12			# set $fp
	
	move $s0, $a0				# salvo l'array lingua
	
	# apertura file
	li   $v0, 13       			# system call per aprire un file
	la   $a0, fileToRead   			# filename
	li   $a1, 0        			# apertura in lettura
	li   $a2, 0
	syscall            			# uscita: $v0
	
	slt $t1, $zero, $v0			# controllo: se $t0 <= 0 significa che il file non è stato aperto
	beq $t1, $zero, exit_no_read		# va al caso default(operazione non valida)

	move $s6, $v0      			# salvo la variabile $v0 in $s6 (id file)


	
	
comincia_lettura:	
	li $v0, 4				# print_string
	la $a0, readingMessage			# avvisa l'utente che il reading è in corso
	syscall


loop:		
	# lettura file
	li   $v0, 14       			# system call per la lettura da un file
	move $a0, $s6      			# file descriptor 
	la   $a1, buffer   			# buffer dove caricare il dato letto
	li   $a2, 1     			# lunghezza buffer hardcoded 
	syscall            			# lettura
		
	beq $v0, $zero, chiudi_file		# lettura terminata
	
	li $t1, 2147483647			# controllo se il numero di caratteri letti supera il max integer	
	beq $s0, $t1, chiudi_max_char		# nel caso sia così, esco
	
	la $a0, lettere				# carico in $a0 l'elenco delle lettere
	la $a1, buffer				# carico in $a1 il buffer appena letto nel file	di lunghezza 1
	move $a2, $s0				# carico in $a2 l'array per la lingua 

	addi $sp, $sp, -4	
	sw $ra, 0($sp)		    		# salvo $ra
	jal conta_occorrenze			
	lw $ra, 0($sp)		    		# ripristino $ra
	addi $sp, $sp, 4
	
	j loop

chiudi_file:
	# chiusura file
	li   $v0, 16       			# system call per la chiusura del file
	move $a0, $s6      			# file descriptor
	syscall            			# close file
	
	j report

chiudi_max_char:
	li $v0, 4				# print_string
	la $a0, maxChar				# avvisa l'utente che il reading è in corso
	syscall
	# chiusura file
	li   $v0, 16       			# system call per la chiusura del file
	move $a0, $s6      			# file descriptor
	syscall            			# close file
	
report:

	move $a0, $s0				# salvo in $a0 l'array per la lingua 
		
	addi $sp, $sp, -4	
	sw $ra, 0($sp)		    		# salvo $ra
	jal stampa_lingua				# stampo il risultato
	lw $ra, 0($sp)		    		# ripristino $ra
	addi $sp, $sp, 4
	j fine_lettura


exit_no_read:
	li $v0, 4
	la $a0, str_errore_file			# file non esistente
	syscall 

	li $v0, 0				# lettura fallita
	
	lw $ra, 0($sp)				# ripristino $ra
	lw $fp, 12($sp)				# ripristino $fp
	lw $s0, 4($sp)				# ripristino $s0
	lw $s6, 8($sp)				# ripristino $s0
	addi $sp, $sp, 16			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante
		
fine_lettura:
	
	la $v0, 1				# lettura riuscita
	
	lw $ra, 0($sp)				# ripristino $ra
	lw $s0, 4($sp)				# ripristino $s0
	lw $s6, 8($sp)				# ripristino $s6
	lw $fp, 12($sp)				# ripristino $fp
	addi $sp, $sp, 16			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante
		
#########################################################################
#########################################################################
#################### Conta occorrenze caratteri #########################
# controlla il contenuto del buffer e aumenta il contenuto
# dell'array lettere conseguentemente. 
# parametri in ingresso:
# $a0 sequenza lettere
# $a1 buffer da leggere (composto da un solo carattere)
# $a2 array da riempire
# valore del parametro in uscita ($v0): 
#	ininfluente 
# variabili usate da salvare nello stack:
# $s0 (sequenza lettere per il confronto)
# $s1 (buffer)
# $s2 (array)

	
conta_occorrenze:
	addi $sp, $sp, -20			# $sp -= 20
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)			 	# salvo $s0
	sw $s1, 8($sp)			 	# salvo $s1
	sw $s2, 12($sp)			 	# salvo $s1
	sw $fp, 16($sp)			 	# salvo $fp
	addi $fp, $sp, 16		 	# set $fp

	move $s0, $a0			 	# $s0 = $a0 lettere
	move $s1, $a1			 	# $s1 = $a1 buffer
	move $s2, $a2			 	# $s2 = $a2 array lingua
	move $t8, $a2				# mi serve per accedere al totale ogni volta

	addi $t3, $zero, 52			# lunghezza loop
	add $t4, $zero, $zero			# contatore
	
	lb $t1, 0($s1)				# $t1 = char del buffer
					 	
	
LoopIncrementa:
	beq $t4, $t3, end_conta_occorrenze	# fine loop, ho finito la stringa di controllo senza trovare occorrenze						
	lb $t0, 0($s0)				# $t0 = char A, B ecc della stringa di controllo   	
    	bne $t0, $t1, incrContatori		# se i 2 caratteri non sono uguali proseguo lungo la stringa di controllo
	# altrimenti: ho trovato l'uguaglianza:
	
	# se $t4 <= 25 sto contando le maiuscole, altrimenti le minuscole (==> devo sottrarre 25)
	li $t7, 1
	slti $t6, $t4, 26
	beq  $t6, $t7, maiuscole
	
	# sono nel caso minuscole
	li 	$t5, 4
	subi	$t4, $t4, 26			# sottraggo 25 al contatore
	mul 	$t5, $t5, $t4 			# i = $t4* 4
	add	$s2, $s2, $t5			# posiziono l'array sul valore corrispondente
	lw 	$t2, 0($s2)		 	# $t2 = EN[i]
	addi    $t3, $t2, 1		 	# $t3 = EN[i] + 1
	sw	$t3, 0($s2)		 	# salvo il risultato
	j incrementa_totale			# esco

maiuscole:
	li 	$t5, 4
	mul 	$t5, $t5, $t4 			# i = $t4* 4
	add	$s2, $s2, $t5			# posiziono l'array sul valore corrispondente
	lw 	$t2, 0($s2)		 	# $t2 = EN[i]
	addi    $t3, $t2, 1		 	# $t3 = EN[i] + 1
	sw	$t3, 0($s2)		 	# salvo il risultato
	j incrementa_totale			# esco

		
incrContatori:
	addi $s0,  $s0, 1   			# avanzo di una posizione nella string lettere
	addi $t4,  $t4, 1   			# incremento il contatore
	j LoopIncrementa
	
incrementa_totale:
	lw $t2, 104($t8)			# $t2 = EN[tot]
	addi $t2, $t2, 1		 	# $t3 = EN[tot] + 1
	sw $t2, 104($t8)			# salvo il risultato
	
	j end_conta_occorrenze

end_conta_occorrenze:	

	lw $ra, 0($sp)				# ripristino $ra
	lw $s0, 4($sp)				# ripristino $s0
	lw $s1, 8($sp)				# ripristino $s1 
	lw $s2, 12($sp)				# ripristino $s2 
	lw $fp, 16($sp)				# ripristino $fp
	addi $sp, $sp, 20			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante
		
#########################################################################
#########################################################################
#################### -------- stampa_lingua ------#########################
# stampa i caratteri fino a quel punto registrati per una lingua
# (numero totale e valore per ogni lettera)
# parametri in ingresso:
# $a0 array lingua (EN,IT, ecc)
# valore del parametro in uscita ($v0): 
#	ininfluente 
# variabili usate da salvare nello stack:
# $s0 (array)
# $s1 (variabile char, lettera dell'alfabeto)
	
stampa_lingua:	

	addi $sp, $sp, -16		 	# $sp -= 12
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)			 	# salvo $s0
	sw $s1, 8($sp)			 	# salvo $s1
	sw $fp, 12($sp)			 	# salvo $fp
	addi $fp, $sp, 12		 	# set $fp

	move $s0, $a0			 	# $s0 = $a0 array lingua
		
	addi $t0, $zero,25			# lunghezza loop
	add $t1, $zero,$zero
	
	li $s1, 'A'    				# primo carattere 'a'  

	#stampa contatore totale
	li $v0, 4
	la $a0, totaleLetterePrompt				
	syscall
	
	addi $t4, $zero, 26			# $t4 = 26		
  	sll $t3, $t4, 2    			# $t3 = $t4* 4 = 104
    	add $t3, $s0, $t3  			# $t3 : address EN[tot]
    	lw  $t2, 0($t3)   			# $t2 = EN[tot]
 
	li $v0, 1				# print int
	move $a0, $t2
	syscall

	# a capo
	li $v0, 4				# print string
	la $a0, acapo				
	syscall
	
	LoopStampa:
 		# carico l'elemento i-esimo dell'array lingua
    		lw  $t2, 0($s0)   		# $t2 = EN[i]
    		addi $s0, $s0, 4		# preparo la prossima lettura
   		
    		move $a0, $s1			# carico anche la lettera corrispondente
    		
  		li $v0, 11
    		syscall            		# syscall 11 = print_character
    		addiu $s1, $s1, 1  		# preparo il prossimo char

 		li $v0, 4			# print string
		la $a0, spazio					
		syscall

  		
    		#stampa intero
 		li $v0, 1
		move $a0, $t2
		syscall
		#endString
		li $v0, 4
		la $a0, endString				
		syscall
		
   		beq $t1, $t0, fineReport 	# i == 25
    		addi $t1,  $t1, 1   		# i= i+ 1
    		j LoopStampa

fineReport:

	lw $ra, 0($sp)				# salvo $ra
	lw $s0, 4($sp)				# ripristino $s1 
	lw $s1, 8($sp)				# ripristino $s2 
	lw $fp, 12($sp)				# ripristino $fp
	addi $sp, $sp, 16			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante

#########################################################################
#########################################################################
#########################################################################
#################### --------scrivi_statistica ------#########################
# procedura per la scritturadella statistica
# (numero totale e valore per ogni lettera)
# parametri in ingresso:
# $a0 = frequenza array lingua (EN,IT, ecc)
# $a1 = array lingua (valori interi)
# valore del parametro in uscita ($v0): 
#	ininfluente 
# variabili usate da salvare nello stack:
# $s0 (array frequenza lingua)
# $s1 (array interi lingua)
# variabili temporanee usate (utile per tenerne traccia)
# $t1 contatore loop lettere (0-25)
# $t2 carica l'elemento i-esimo dell'array_lunghezze
# $t3 (variabile char, lettera dell'alfabeto)
# $f12 per il il float (lo uso anche perché è argomento del print float)

	
scrivi_statistica:	

	addi $sp, $sp, -16		 	# $sp -= 16
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)			 	# salvo $s0
	sw $s1, 8($sp)			 	# salvo $s1
	sw $fp, 12($sp)			 	# salvo $fp
	addi $fp, $sp, 12		 	# set $fp

	move $s0, $a0			 	# $s0 = $a0 array FREQUENZA lingua
	move $s1, $a1			 	# $s1 = $a1 array lingua
	
	addi $t0, $zero,25			# lunghezza loop
	add $t1, $zero,$zero
	
	li $t3, 'A'    				# primo carattere 'a'  

	#stampa contatore totale
	li $v0, 4
	la $a0, totaleLetterePrompt				
	syscall
	
	addi $t4, $zero, 26					
  	sll $t3, $t4, 2    			# $t3 = $t4* 4 = 104
    	add $t3, $s1, $t3  			# $t3 : address EN[tot]
    	lw  $t2, 0($t3)   			# $t2 = EN[tot]
    					
 
	li $v0, 1				# print int
	move $a0, $t2
	syscall

	# a capo
	li $v0, 4				# print string
	la $a0, acapo				
	syscall
	
	move $t6, $t2				# salvo EN[tot]
	bnez $t2, LoopWriteStat			# se EN[tot] non è 0, stampo le statistiche
	
	# a capo
	li $v0, 4				# print string
	la $a0, statNoAvailable				
	syscall
	
	j fineWriteStat
	
	LoopWriteStat:
 		# carico l'elemento i-esimo dell'array lingua
    		lw  $t2, 0($s1)   		# $t2 = EN[i]
    		addi $s1, $s1, 4   		# avanzo di un elemento nell'array lingua

    		move $a0, $t3			# carico anche la lettera corrispondente da stampare
    		
  		li $v0, 11
    		syscall            		# syscall 11 = print_character
    		addiu $t3, $t3, 1  		# set $s1 to the next character

 		li $v0, 4			# print string
		la $a0, spazio					
		syscall

   		#stampa intero
 		li $v0, 1
		move $a0, $t2
		syscall
 
 		li $v0, 4			# print string
		la $a0, spazio					
		syscall
		
  		# carico l'elemento i-esimo dell'array FREQUENZA lingua
      		l.s  $f12, 0($s0)   		# $f12 = frEN[i]
   		
		# stampa float
		li $v0, 2			# print float
		syscall
		
		addi $s0, $s0, 8			# avanzo di una posizione nell'array frequenze
		
		li $v0, 4			# print string
		la $a0, percento					
		syscall

		#endString
		li $v0, 4
		la $a0, endString				
		syscall
		
   		beq $t1, $t0, fineWriteStat 	# i == 25
    		addi $t1,  $t1, 1   		# i= i+ 1 incremento il contatore
    		j LoopWriteStat

fineWriteStat:
	lw $ra, 0($sp)				# ripristino $ra
	lw $s0, 4($sp)				# ripristino $s0 
	lw $s1, 8($sp)				# ripristino $s1 
	lw $fp, 12($sp)				# ripristino $fp
	addi $sp, $sp, 16			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante

#########################################################################
#################### --------azzera_array ------#########################
# procedura per l'azzeramento del file di lingua ignota prima di una nuova lettura
# l'array nel caso della lingua da determinare NON deve essere incrementale
# $a0 = array lingua (valori interi)
# valore del parametro in uscita ($v0): 
#	ininfluente 
# variabili usate da salvare nello stack:
# $s0 (array)

	
azzera_array:	

	addi $sp, $sp, -12		 	# $sp -= 20
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)			 	# salvo $s0
	sw $fp, 8($sp)			 	# salvo $fp
	addi $fp, $sp, 8		 	# set $fp

	move $s0, $a0			 	# $s0 = $a0 array lingua
	
	addi $t0, $zero,26			# lunghezza loop
	add $t1, $zero,$zero
	li $t2, 0				# carico 0
		
	LoopAzzeraArray:
 		# carico l'elemento i-esimo dell'array lingua
    		sw  $t2, 0($s0)   		# XX[i] = 0
    		addi $s0, $s0, 4   		# avanzo di un elemento nell'array lingua

  		
   		beq $t1, $t0, fineAzzeraArray 	# i == 25
    		addi $t1,  $t1, 1   		# i= i+ 1 incremento il contatore
    		j LoopAzzeraArray

fineAzzeraArray:
	lw $ra, 0($sp)				# ripristino $ra
	lw $s0, 4($sp)				# ripristino $s0 
	lw $fp, 8($sp)				# ripristino $fp
	addi $sp, $sp, 12			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante

#########################################################################
#########################################################################

#########################################################################
#################### --------calcola_statistica ------#########################
# procedura per il calcolo delle frequenze
# stampa i caratteri fino a quel punto registrati per una lingua
# (numero totale e valore per ogni lettera)
# parametri in ingresso:
# $a0 = array lingua (EN,IT, ecc)
# valore del parametro in uscita ($v0): 
#	ininfluente 
# variabili usate da salvare nello stack:
# $s1 (array)
# $s2 (variabile char, lettera dell'alfabeto)
	
	
calcola_statistica:	

	addi $sp, $sp, -16		 	# $sp -= 16
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)			 	# salvo $s1
	sw $s1, 8($sp)			 	# salvo $s1
	sw $fp, 12($sp)			 	# salvo $fp
	addi $fp, $sp, 12		 	# set $fp

	move $s0, $a0			 	# $s0 = $a0 array frequenza
	move $s1, $a1			 	# $s0 = $a0 array lingua
		
	addi $t0, $zero,25			# lunghezza loop
	add $t1, $zero,$zero
	
	addi $t4, $zero, 26					
  	sll $t3, $t4, 2    			# $t3 = i* 4
    	add $t3, $s1, $t3  			# $t3 : address EN[tot]
    	lw  $t2, 0($t3)   			# $t2 = EN[tot]
	
	move $t6, $t2				# salvo $t2 = EN[tot]
	bnez $t2, LoopCalcolaStat		# se EN[tot] non è 0, calcolo le frequenze
	
	li $v0, 0				# se devo uscire senza calcolare le statistiche, $v0 = 0	
	j fineCalcolaStat
	
	LoopCalcolaStat:
 		# carico l'elemento i-esimo dell'array lingua
     		lw  $t2, 0($s1)   		# $t2 = EN[i]   		
 
		mtc1 $t2, $f6			# $f6 = $t2 (EN[i])		
  		cvt.s.w $f6, $f6		# conversione int -> float
  		
		mtc1 $t6, $f2			# $f2 = $t6 (EN[tot]) 
		cvt.s.w $f2, $f2		# conversione int -> double
		
		div.s $f2, $f6, $f2		# $f2 = int / EN[tot]
		
		li $t5, 100
		mtc1 $t5, $f4			# $f4 = 100
		cvt.s.w $f4, $f4		# conversione int -> double
				
		mul.s $f12, $f2, $f4		# $f12 = freq*100
    		s.s $f12, 0($s0)
    				
   		beq $t1, $t0, fineCalcolaStat 	# i == 25
    		addi $t1,  $t1, 1   		# i= i+ 1
       		addi $s1, $s1, 4   		# i= i+ 4
    		addi $s0, $s0, 4   		# i= i+ 4
    		j LoopCalcolaStat

fineCalcolaStat:
	sw $ra, 0($sp)				# ripristino $ra
	lw $s0, 4($sp)				# ripristino $s0 
	lw $s1, 8($sp)				# ripristino $s1 
	lw $fp, 12($sp)				# ripristino $fp
	addi $sp, $sp, 16			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante
											
################ fine procedura scrivi_statistica ################
#################### estrai_nome_file-#########################
# procedura che rimuove il carattere \n dal nome del file in ingresso
# parametri in ingresso:
# nessuno
# valore del parametro in uscita ($v0): 
#	ininfluente 
# variabili usate da salvare nello stack:
# nessuna
	
estrai_nome_file:	

	addi $sp, $sp, -4		 	# $sp -= 12
	sw $fp, 0($sp)			 	# salvo $fp
	addi $fp, $sp, 0		 	# set $fp
	
	# rimozione del carattere \n
	la $a0,fileToRead	
	add $a0,$a0,29				# vai alla fine di fileToRead
	
	rLFloop: 
		lb 	$v0,0($a0)	
		bnez $v0,rLFdone  		# se l'ultimo carattere non è 0, esci, altrimenti rimuovilo
		sub $a0,$a0,1	
		j rLFloop 
										 
	rLFdone: 
		sb $0,0($a0)

	lw $fp, 0($sp)				# ripristino $fp
	addi $sp, $sp, 4			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante
	
################ fine procedura estrai_nome_file ################
#################### determina_lingua #########################
# valuta gli sqrt e determina di conseguenza la lingua più probabile
# parametri in ingresso:
# nessuno
# parametri in uscita
# $v0 è l'array risultato
# variabili usate da salvare nello stack:
# $s0 = il buffer contenente la lingua risultante
# $s2 = l'array che si sta controllando (EN, IT, FR)

determina_lingua:
	addi $sp, $sp, -16		 	# $sp -= 12
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)			 	# salvo $s0
	sw $s2, 8($sp)			 	# salvo $s2
	sw $fp, 12($sp)			 	# salvo $fp
	addi $fp, $sp, 12		 	# set $fp
	
	li $t5, 510			# il minimo iniziale lo scelgo grande più del massimo numero possibile 
						# (in realtà calcolo MOLTO approssimato)
					# ogni freq è in percentuale, quindi massimo valore possibile 100. 
					# ogni differenza al quadrato è quindi al massimo 10000. x 26= 260000, sqrt(26000) - 510 c.a
	mtc1 $t5, $f16			# $f16 somma		
  	cvt.s.w $f16, $f16		# conversione int -> float
  	
  	la $s0, nessunaLingua
	
comparaEN:	
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strComparoInglese				
	syscall

	la $s2, EN
	
	addi $t4, $zero, 26					
  	sll $t3, $t4, 2    			# $t3 = i* 4
    	add $t3, $s2, $t3  			# $t3 : address EN[tot]
    	lw  $t2, 0($t3)   			# $t2 = EN[tot]

	move $t6, $t2				# salvo EN[tot]
	bnez $t2, esegui_calcolo_EN			# se EN[tot] non è 0, proseguo con l'analisi
	
	# a capo
	li $v0, 4				# print string
	la $a0, statNoAvailable				
	syscall
	
	j comparaIT

esegui_calcolo_EN:		
	la $a0, frEN				# lingua: francese	

	addi $sp, $sp, -4	
	sw $ra, 0($sp)		    		# salvo $ra
	jal compara_array			
	lw $ra, 0($sp)		    		# ripristino $ra
	addi $sp, $sp, 4
	
	mov.s $f12, $f0

	li $v0, 4
	la $a0, sqrt
	syscall
	
	# stampa float
	li $v0, 2				# print float
	syscall
	
	c.lt.s $f0, $f16
	bc1t nuovo_minimoEN
	j comparaIT


comparaIT:	
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strComparoItaliano				
	syscall

	la $s2, IT
	
	addi $t4, $zero, 26					
  	sll $t3, $t4, 2    			# $t3 = i* 4
    	add $t3, $s2, $t3  			# $t3 : address EN[tot]
    	lw  $t2, 0($t3)   			# $t2 = EN[tot]

	move $t6, $t2				# salvo EN[tot]
	bnez $t2, esegui_calcolo_IT			# se EN[tot] non è 0, proseguo con l'analisi
	
	# a capo
	li $v0, 4				# print string
	la $a0, statNoAvailable				
	syscall
	
	j comparaFR

esegui_calcolo_IT:		

	la $a0, frIT				# lingua: francese	

	addi $sp, $sp, -4	
	sw $ra, 0($sp)		    		# salvo $ra
	jal compara_array			
	lw $ra, 0($sp)		    		# ripristino $ra
	addi $sp, $sp, 4
	
	mov.s $f12, $f0

	li $v0, 4
	la $a0, sqrt
	syscall
	
	# stampa float
	li $v0, 2				# print float
	syscall
	
	c.lt.s $f0, $f16
	bc1t nuovo_minimoIT

comparaFR:	
	li $v0, 4				# comando per la syscall di un print string
	la $a0, strComparoFrancese				
	syscall

	la $s2, FR
	
	addi $t4, $zero, 26					
  	sll $t3, $t4, 2    			# $t3 = i* 4
    	add $t3, $s2, $t3  			# $t3 : address EN[tot]
    	lw  $t2, 0($t3)   			# $t2 = EN[tot]

	move $t6, $t2				# salvo EN[tot]
	bnez $t2, esegui_calcolo_FR			# se EN[tot] non è 0, proseguo con l'analisi
	
	# a capo
	li $v0, 4				# print string
	la $a0, statNoAvailable				
	syscall
	
	j stampa_risultato

esegui_calcolo_FR:		
	la $a0, frFR				# lingua: francese	

	addi $sp, $sp, -4	
	sw $ra, 0($sp)		    		# salvo $ra
	jal compara_array			
	lw $ra, 0($sp)		    		# ripristino $ra
	addi $sp, $sp, 4
	
	mov.s $f12, $f0

	li $v0, 4
	la $a0, sqrt
	syscall
	
	# stampa float
	li $v0, 2				# print float
	syscall
	
	c.lt.s $f0, $f16
	bc1t nuovo_minimoFR
	j stampa_risultato

		
nuovo_minimoEN:
	mov.s $f16, $f0
	la $s0, strLeggiInglese
	j comparaIT

nuovo_minimoIT:
	mov.s $f16, $f0
	la $s0, strLeggiItaliano
	j comparaFR

nuovo_minimoFR:
	mov.s $f16, $f0
	la $s0, strLeggiFrancese
	j stampa_risultato

stampa_risultato:

	li $v0, 4
	la $a0, strStampaRisultato
	syscall

	li $v0, 4
	move $a0, $s0
	syscall
	
	lw $ra, 0($sp)				# ripristino $ra
	lw $s0, 4($sp)				# ripristino $s1 
	lw $s2, 8($sp)				# ripristino $s2 
	lw $fp, 12($sp)				# ripristino $fp
	addi $sp, $sp, 16			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante

################ fine procedura determina_lingua ################
#################### compara_array #########################
# procedura che determina lo sqrt tra le frequenze delle lingue note
# e la frequenza in analisi ai fini di determinare con maggiore probabilità 
# possibile la lingua ignota analizzata
# parametri in ingresso:
# $a0 array 1
# $a1 array 2
# parametri in uscita:
# $f10 sqrt  
# variabili usate da salvare nello stack:
# $s0 array 1
# $s1 array 2

compara_array:
	addi $sp, $sp, -16		 	# $sp -= 16
	sw $ra, 0($sp)				# salvo $ra
	sw $s0, 4($sp)			 	# salvo $s0
	sw $s1, 8($sp)			 	# salvo $s1
	sw $fp, 12($sp)			 	# salvo $fp
	addi $fp, $sp, 12		 	# set $fp
	
	move $s0, $a0				# salvo in $s0 il secondo array frequenze(es: frEN)
	la $s1, frXX				# salvo in $s1 il primo array frXX
		
	# calcolo il quadrato della differenza di ciascun elemento dei 2 array
	addi $t0, $zero,25			# lunghezza loop
	add $t1, $zero,$zero			# contatore
	
	li $t5, 0			# somma inizialmente a 0
	mtc1 $t5, $f10			# $f10 somma		
  	cvt.s.w $f10, $f10		# conversione int -> float
		
	LoopSomma:
  		# carico l'elemento i-esimo dell'array FREQUENZA lingua
      		l.s  $f2, 0($s1)   		# $f2 = frXX[i]
      		l.s  $f4, 0($s0)   		# $f4 = frEN[i]

		sub.s $f6, $f4, $f2		# calcolo la differenza tra le 2 frequenze
 		
		mul.s $f8, $f6, $f6		# calcolo il quadrato
		
		add.s $f10, $f10, $f8		# sommo al totale 
 				
   		beq $t1, $t0, fineSomma 	# i == 25
    		addi $t1,  $t1, 1   		# i= i+ 1
       		addi $s1, $s1, 4   		# i= i+ 4
    		addi $s0, $s0, 4		# i= i+ 4
    		j LoopSomma
	
		

fineSomma:

	sqrt.s $f0, $f10			# risultato in $f0 anziché $v0 perché è un float
	
	lw $ra, 0($sp)				# ripristino $ra
	lw $s0, 4($sp)				# ripristino $s0 
	lw $s1, 8($sp)				# ripristino $s1 
	lw $fp, 12($sp)				# ripristino $fp
	addi $sp, $sp, 16			# dealloco stack frame
	jr $ra					# ritorno del controllo al chiamante

#################### fine compara_array #########################

