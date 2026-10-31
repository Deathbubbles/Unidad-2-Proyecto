INCLUDE Irvine32.inc

; ---------- Constantes ----------
MAX_PRODUCTOS   = 10                
TAM_REGISTRO    = 44                
OFF_NOMBRE      = 8                
OFF_PRECIO      = 36                
OFF_EXISTENCIA  = 40                
ACCION_REGISTRAR = 1                
ACCION_BUSCAR    = 2                
ACCION_RECIBIR   = 3                
ACCION_VENDER    = 4                
ACCION_RESUMEN   = 5                
ACCION_ARCHIVO   = 6               
ACCION_REGLA     = 7                
ACCION_NINGUNA   = 0                

; Regla del negocio: alerta de existencia minima. 
MIN_EXISTENCIA   = 5

; Archivo inventario.txt: 
TAM_BUFFER_ARCHIVO = 512            ; espacio para el texto del archivo

.data
    ; ---------- Catalogo ----------
    catalogo            BYTE MAX_PRODUCTOS * TAM_REGISTRO DUP(0)
    numProductos        DWORD 0     
    cambiosSinGuardar   DWORD 0     ; 1 si hay cambios que no se han guardado

    direccionRegistro   DWORD 0     
    accion              DWORD 0     ; Se usa como bandera para las acciones
    centavosMostrados   DWORD 0     
    numeroMostrado      DWORD 0     ; 1 = pesos, 2 = existencia, 3 = unidades del resumen
    regresoDinero       DWORD 0     ; 1 = tabla, 2 = total de venta, 3 = valor del inventario, 4 = ingresos

    ; ---------- Ventas ----------
    cantidadVenta       DWORD 0     ; unidades que se quieren vender
    importeVenta        DWORD 0     ; total de la venta en centavos
    ingresosSesion      DWORD 0     ; dinero vendido en esta sesion, en centavos

    ; ---------- Resumen ----------
    unidadesTotales     DWORD 0     ; suma de las existencias de todos los productos
    valorInventario     DWORD 0     ; suma de precio * existencia, en centavos

    ; ---------- Archivo ----------
    nombreArchivo       BYTE "inventario.txt", 0
    manejadorArchivo    DWORD 0     ; handle que devuelve CreateOutputFile u OpenInputFile
    bytesPedidos        DWORD 0     ; bytes que se quieren escribir
    bytesLeidos         DWORD 0     ; bytes que realmente se leyeron
    registrosPendientes DWORD 0     ; productos que faltan por guardar
    retornoNumero       DWORD 0     ; 1 = era el precio, 2 = era la existencia
    conteoNuevo         DWORD 0     ; productos leidos del archivo hasta ahora
    bufferArchivo       BYTE TAM_BUFFER_ARCHIVO DUP(0)   ; texto del archivo
    catalogoNuevo       BYTE MAX_PRODUCTOS * TAM_REGISTRO DUP(0)  ; aqui se arma lo leido

    textoIngresado      BYTE 80 DUP(0)  ; lo que escribe el usuario

    ; ---------- Menus ----------
    msgTitulo       BYTE "= TIENDA DE VIDEOJUEGOS: VENTAS E INVENTARIO =", 0Ah, 0

    msgMenuPrincipal BYTE 0Ah
                     BYTE "1. Registrar y consultar", 0Ah
                     BYTE "2. Recibir mercancia", 0Ah
                     BYTE "3. Vender", 0Ah
                     BYTE "4. Mostrar resumen", 0Ah
                     BYTE "5. Guardar y cargar", 0Ah
                     BYTE "6. Regla del negocio (alerta de existencia minima)", 0Ah
                     BYTE "0. Salir", 0Ah
                     BYTE "Elige una opcion (0-6): ", 0

    msgMenuRegistrar BYTE 0Ah
                     BYTE "- REGISTRAR Y CONSULTAR -", 0Ah
                     BYTE "1. Registrar videojuego", 0Ah
                     BYTE "2. Mostrar inventario", 0Ah
                     BYTE "3. Buscar por codigo", 0Ah
                     BYTE "0. Volver", 0Ah
                     BYTE "Elige una opcion (0-3): ", 0

    msgMenuArchivo   BYTE 0Ah
                     BYTE "- GUARDAR Y CARGAR -", 0Ah
                     BYTE "1. Guardar catalogo", 0Ah
                     BYTE "2. Cargar catalogo", 0Ah
                     BYTE "0. Volver", 0Ah
                     BYTE "Elige una opcion (0-2): ", 0

    msgOpcionInvalida  BYTE "Opcion invalida.", 0Ah, 0
    msgDespedida       BYTE "Hasta luego.", 0Ah, 0

    ; ---------- Mensajes de registro y consulta ----------
    msgPedirCodigo      BYTE "Codigo (formato ABC-123): ", 0
    msgPedirNombre      BYTE "Nombre del videojuego (1 a 25 caracteres): ", 0
    msgPedirPrecio      BYTE "Precio en MXN (0.01 a 9999.99): ", 0
    msgPedirExistencia  BYTE "Existencia inicial (0 a 100): ", 0
    msgRegistroExitoso  BYTE "Videojuego registrado correctamente.", 0Ah, 0

    msgDatoInvalido     BYTE "Dato invalido.", 0Ah, 0
    msgCodigoRepetido   BYTE "Ese codigo ya esta registrado. No se agrego el videojuego.", 0Ah, 0
    msgCatalogoLleno    BYTE "No hay espacio: el catalogo ya tiene 10 videojuegos.", 0Ah, 0
    msgInventarioVacio  BYTE "El inventario esta vacio.", 0Ah, 0
    msgCodigoNoExiste   BYTE "No existe un videojuego con ese codigo.", 0Ah, 0

    msgEncabezadoTabla  BYTE "CODIGO | NOMBRE | PRECIO | EXISTENCIA", 0Ah, 0
    msgSeparador        BYTE " | ", 0
    msgMoneda           BYTE " MXN", 0

    ; ---------- Mensajes de recibir mercancia ----------
    msgPedirCantidad     BYTE "Cantidad (1 a 100): ", 0
    msgExcedeCapacidad   BYTE "La existencia no puede pasar de 100. No se recibio la mercancia.", 0Ah, 0
    msgMercanciaRecibida BYTE "Mercancia recibida. Producto actualizado:", 0Ah, 0

    ; ---------- Mensajes de venta ----------
    msgSinExistencia     BYTE "Existencia insuficiente. No se realizo la venta.", 0Ah, 0
    msgDesbordamiento    BYTE "El importe es demasiado grande. No se realizo la venta.", 0Ah, 0
    msgVentaRealizada    BYTE "Venta realizada. Total a cobrar: ", 0

    ; ---------- Mensajes del resumen ----------
    msgResumenTitulo     BYTE 0Ah, "--- RESUMEN ---", 0Ah, 0
    msgResumenUnidades   BYTE "Unidades en inventario: ", 0
    msgResumenValor      BYTE "Valor del inventario: ", 0
    msgResumenIngresos   BYTE "Ingresos de la sesion: ", 0

    ; ---------- Mensajes de la regla del negocio ----------
    msgAlertaTitulo      BYTE 0Ah, "Productos con existencia baja (menos de 5 unidades):", 0Ah, 0
    msgSinAlertas        BYTE "Ningun producto tiene existencia baja.", 0Ah, 0
    msgAlertaVenta       BYTE "ALERTA: existencia baja, quedan menos de 5 unidades.", 0Ah, 0

    ; ---------- Mensajes de archivo ----------
    msgGuardado          BYTE "Catalogo guardado en inventario.txt.", 0Ah, 0
    msgCargado           BYTE "Catalogo cargado correctamente.", 0Ah, 0
    msgErrorCrear        BYTE "No se pudo crear el archivo. No se guardo nada.", 0Ah, 0
    msgErrorEscribir     BYTE "No se escribieron todos los datos. Intenta guardar otra vez.", 0Ah, 0
    msgArchivoNoExiste   BYTE "No existe el archivo inventario.txt. El catalogo no cambio.", 0Ah, 0
    msgArchivoInvalido   BYTE "El archivo esta danado o tiene un formato incorrecto. El catalogo no cambio.", 0Ah, 0
    msgAvisoSalir        BYTE "Hay cambios sin guardar. Salir de todos modos? (S/N): ", 0

.code
main PROC
    mov edx, OFFSET msgTitulo
    call WriteString

    ; ==================================================================
    ; MENU PRINCIPAL
    ; ==================================================================
menuPrincipal:
    mov accion, ACCION_NINGUNA
    mov edx, OFFSET msgMenuPrincipal
    call WriteString

    mov edx, OFFSET textoIngresado  ; EDX = donde se guarda lo escrito
    mov ecx, 79                     ; ECX = maximo de caracteres (80 - 1)
    call ReadString                 ; EAX = cuantos caracteres se escribieron

    ; Validacion: un solo caracter entre '0' y '6'
    cmp eax, 1
    jne opcionInvalidaPrincipal
    mov al, textoIngresado          
    cmp al, '0'
    jb opcionInvalidaPrincipal
    cmp al, '6'
    ja opcionInvalidaPrincipal

    cmp al, '0'
    je salir
    cmp al, '1'
    je menuRegistrar
    cmp al, '2'
    je recibirMercancia
    cmp al, '3'
    je venderJuego
    cmp al, '4'
    je mostrarResumen
    cmp al, '5'
    je menuArchivo
    jmp reglaAlertas                ; opcion 6

opcionInvalidaPrincipal:
    mov edx, OFFSET msgOpcionInvalida
    call WriteString
    jmp menuPrincipal

    ; ==================================================================
    ; SUBMENU 1: REGISTRAR Y CONSULTAR
    ; ==================================================================
menuRegistrar:
    mov edx, OFFSET msgMenuRegistrar
    call WriteString

    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString

    cmp eax, 1
    jne opcionInvalidaRegistrar
    mov al, textoIngresado
    cmp al, '0'
    jb opcionInvalidaRegistrar
    cmp al, '3'
    ja opcionInvalidaRegistrar

    cmp al, '0'
    je menuPrincipal                ; 0 = volver al menu principal
    cmp al, '1'
    je registrarJuego
    cmp al, '2'
    je mostrarInventario
    jmp buscarPorCodigo             ; opcion 3

opcionInvalidaRegistrar:
    mov edx, OFFSET msgOpcionInvalida
    call WriteString
    jmp menuRegistrar

    ; ==================================================================
    ; OPCION 1: REGISTRAR VIDEOJUEGO
    ; ==================================================================
registrarJuego:
    cmp numProductos, MAX_PRODUCTOS
    jb calcularRegistroLibre
    mov edx, OFFSET msgCatalogoLleno   
    jmp mostrarError

calcularRegistroLibre:
    mov eax, numProductos
    mov ebx, TAM_REGISTRO
    mul ebx
    add eax, OFFSET catalogo
    mov direccionRegistro, eax
    mov accion, ACCION_REGISTRAR

    ; ---------- Codigo: formato ABC-123 ----------
pedirCodigo:
    mov edx, OFFSET msgPedirCodigo
    call WriteString
    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString

    ; Validacion
    mov esi, OFFSET textoIngresado
    mov ecx, 3
validarLetras:
    mov bl, [esi]
    cmp bl, 'A'
    jb errorDatoInvalido
    cmp bl, 'Z'
    ja errorDatoInvalido
    inc esi
    loop validarLetras

    mov bl, [esi]
    cmp bl, '-'
    jne errorDatoInvalido
    inc esi

    mov ecx, 3
validarDigitos:
    mov bl, [esi]
    cmp bl, '0'
    jb errorDatoInvalido
    cmp bl, '9'
    ja errorDatoInvalido
    inc esi
    loop validarDigitos

    mov bl, [esi]
    cmp bl, 0                       ; despues del ultimo digito debe terminar
    jne errorDatoInvalido

    ; ---------- Buscar el codigo en el catalogo ----------
    mov esi, OFFSET catalogo
    mov ecx, numProductos          
    cmp ecx, 0
    je codigoNoEncontrado           
buscarRegistro:
    mov ebx, esi                    
    mov edi, OFFSET textoIngresado  
    mov edx, 7                     
compararCodigo:
    mov al, [esi]
    cmp al, [edi]
    jne codigoDistinto
    inc esi
    inc edi
    dec edx
    jnz compararCodigo

    mov esi, ebx                    ; el codigo existe: ESI = su registro
    cmp accion, ACCION_BUSCAR
    je mostrarUnProducto            ; buscaba: lo muestra
    cmp accion, ACCION_RECIBIR
    je pedirCantidad                ; recibia mercancia: sigue con la cantidad
    cmp accion, ACCION_VENDER
    je pedirCantidad                ; vendia: sigue con la cantidad
    jmp errorCodigoRepetido         ; registraba: no se permiten repetidos

codigoDistinto:
    mov esi, ebx
    add esi, TAM_REGISTRO           ; siguiente registro
    loop buscarRegistro

codigoNoEncontrado:
    cmp accion, ACCION_REGISTRAR
    jne errorCodigoNoExiste         ; buscaba o recibia y no existe

    mov esi, OFFSET textoIngresado  ; registraba y esta libre
    mov edi, direccionRegistro      
    mov ecx, 8
copiarCodigo:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop copiarCodigo

    ; ---------- Nombre: de 1 a 25 caracteres ----------
    mov edx, OFFSET msgPedirNombre
    call WriteString
    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString
    cmp eax, 1
    jb errorDatoInvalido            
    cmp eax, 25
    ja errorDatoInvalido            

    mov esi, OFFSET textoIngresado  
    mov edi, direccionRegistro
    add edi, OFF_NOMBRE             ; el nombre va 8 bytes despues
copiarNombre:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne copiarNombre

    ; ---------- Precio: "185", "185.5" o "185.50" -> centavos ----------
    mov edx, OFFSET msgPedirPrecio
    call WriteString
    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString

    mov esi, OFFSET textoIngresado
    mov eax, 0                      ; EAX = pesos y luego centavos
    mov ecx, 0                      ; ECX = digitos de la parte entera
precioPesos:
    movzx ebx, BYTE PTR [esi]
    cmp bl, 0
    je precioSinPunto               ; termino sin punto decimal
    cmp bl, '.'
    je precioPunto
    cmp bl, '0'
    jb errorDatoInvalido            ; simbolo, espacio o coma: rechazado
    cmp bl, '9'
    ja errorDatoInvalido
    cmp ecx, 4
    jae errorDatoInvalido           ; mas de 4 digitos: pasa de $9999
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc ecx
    inc esi
    jmp precioPesos

precioPunto:
    cmp ecx, 0
    je errorDatoInvalido            ; ".50" no tiene pesos
    inc esi                         ; salta el punto
    imul eax, 100                   ; pesos a centavos
    mov edx, 0                      ; EDX = decimales leidos
precioDecimales:
    movzx ebx, BYTE PTR [esi]
    cmp bl, 0
    je precioFinDecimales
    cmp bl, '0'
    jb errorDatoInvalido
    cmp bl, '9'
    ja errorDatoInvalido
    cmp edx, 2
    jae errorDatoInvalido           ; tercer decimal: rechazado
    sub bl, '0'
    cmp edx, 0
    jne precioSumarDecimal
    imul ebx, 10                    ; el primer decimal son decenas de centavo
precioSumarDecimal:
    add eax, ebx
    inc edx
    inc esi
    jmp precioDecimales

precioFinDecimales:
    cmp edx, 0
    je errorDatoInvalido            ; "12." sin decimales
    jmp precioValidarRango

precioSinPunto:
    cmp ecx, 0
    je errorDatoInvalido            ; vacio
    imul eax, 100                   ; pesos enteros a centavos

precioValidarRango:
    cmp eax, 1
    jb errorDatoInvalido            ; menos de $0.01
    cmp eax, 999999
    ja errorDatoInvalido            ; mas de $9999.99
    mov esi, direccionRegistro
    mov [esi + OFF_PRECIO], eax     ; precio en centavos

    ; ---------- Existencia: entero de 0 a 100 ----------
    mov edx, OFFSET msgPedirExistencia
    call WriteString
    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString
    cmp eax, 1
    jb errorDatoInvalido            ; vacia
    cmp eax, 3
    ja errorDatoInvalido            ; mas de 3 caracteres

    mov ecx, eax                    ; ECX = caracteres a revisar
    mov esi, OFFSET textoIngresado
    mov eax, 0
existenciaDigitos:
    movzx ebx, BYTE PTR [esi]
    cmp bl, '0'
    jb errorDatoInvalido
    cmp bl, '9'
    ja errorDatoInvalido
    sub bl, '0'
    imul eax, 10                    ; resultado = resultado * 10 + digito
    add eax, ebx
    inc esi
    loop existenciaDigitos
    cmp eax, 100
    ja errorDatoInvalido
    mov esi, direccionRegistro
    mov [esi + OFF_EXISTENCIA], eax ; existencia

    ; ---------- Todo es valido: ahora si cuenta como producto ----------
    inc numProductos
    mov cambiosSinGuardar, 1
    mov edx, OFFSET msgRegistroExitoso
    call WriteString
    jmp menuRegistrar

    ; ---------- Errores ----------
    ; Los datos con formato o rango incorrecto saltan directo a errorDatoInvalido,
    ; que carga el mensaje unico "dato invalido" y sigue en mostrarError.
    ; Los avisos con mensaje propio cargan su mensaje en EDX y saltan a mostrarError.
errorCodigoRepetido:
    mov edx, OFFSET msgCodigoRepetido
    jmp mostrarError

errorCodigoNoExiste:
    mov edx, OFFSET msgCodigoNoExiste
    jmp mostrarError

errorExcedeCapacidad:
    mov edx, OFFSET msgExcedeCapacidad
    jmp mostrarError

errorSinExistencia:
    mov edx, OFFSET msgSinExistencia
    jmp mostrarError

errorDesbordamiento:
    mov edx, OFFSET msgDesbordamiento
    jmp mostrarError

errorDatoInvalido:
    mov edx, OFFSET msgDatoInvalido

mostrarError:
    call WriteString                ; muestra el mensaje que esta en EDX

    ; ---------- Volver al menu de donde se vino ----------
    ; Archivo vuelve a su submenu. Las demas acciones de recibir en adelante
    ; (recibir, vender, resumen) son del menu principal; lo demas, del submenu 1.
volverAlMenu:
    cmp accion, ACCION_ARCHIVO
    je menuArchivo
    cmp accion, ACCION_RECIBIR
    jae menuPrincipal
    jmp menuRegistrar

    ; ==================================================================
    ; OPCION 2: MOSTRAR INVENTARIO
    ; ==================================================================
mostrarInventario:
    cmp numProductos, 0
    jne hayProductos
    mov edx, OFFSET msgInventarioVacio
    jmp mostrarError
hayProductos:
    mov esi, OFFSET catalogo        ; ESI = primer registro
    mov ecx, numProductos           ; ECX = cuantos registros mostrar

    ; ---------- Tabla: encabezado y una fila por registro ----------
imprimirTabla:
    mov edx, OFFSET msgEncabezadoTabla
    call WriteString

tablaFila:
    cmp accion, ACCION_REGLA
    jne filaNormal
    cmp DWORD PTR [esi + OFF_EXISTENCIA], MIN_EXISTENCIA
    jae filaSaltar                  ; la regla solo muestra los de existencia baja
filaNormal:
    mov edx, esi                    ; el codigo esta al inicio del registro
    call WriteString
    mov edx, OFFSET msgSeparador
    call WriteString

    mov edx, esi                    ; el nombre esta 8 bytes despues
    add edx, OFF_NOMBRE
    call WriteString
    mov edx, OFFSET msgSeparador
    call WriteString

    ; Precio: lo escribe escribirDinero y regresa a regresoTabla
    mov eax, [esi + OFF_PRECIO]     ; precio en centavos
    mov regresoDinero, 1
    jmp escribirDinero

regresoTabla:
    mov edx, OFFSET msgSeparador
    call WriteString
    mov eax, [esi + OFF_EXISTENCIA]
    mov numeroMostrado, 2
    jmp convertirNumero             ; escribe la existencia y regresa a finFila

finFila:
    call Crlf
    cmp accion, ACCION_VENDER
    jne filaSaltar
    cmp DWORD PTR [esi + OFF_EXISTENCIA], MIN_EXISTENCIA
    jae filaSaltar                  ; despues de una venta avisa si quedo poco
    mov edx, OFFSET msgAlertaVenta
    call WriteString
filaSaltar:
    add esi, TAM_REGISTRO           ; siguiente registro
    dec ecx
    jnz tablaFila
    jmp volverAlMenu

    ; ---------- Convertir un numero a texto y escribirlo ----------
    ; Divide entre 10, guarda los residuos en la pila para invertir su
    ; orden y les suma '0' (ASCII) al sacarlos.
convertirNumero:
    mov ebx, 10
    mov edi, 0                      ; EDI cuenta los digitos
extraerDigitos:
    mov edx, 0
    div ebx                         ; EDX = digito, EAX = lo que falta
    push edx
    inc edi
    cmp eax, 0
    jne extraerDigitos
escribirDigitos:
    pop eax
    add al, '0'
    call WriteChar
    dec edi
    jnz escribirDigitos

    cmp numeroMostrado, 1
    je mostrarCentavos              ; ya escribio los pesos
    cmp numeroMostrado, 3
    je resumenValor                 ; ya escribio las unidades del resumen
    jmp finFila                     ; ya escribio la existencia

    ; ---------- Escribir un importe en centavos como $PESOS.CC MXN ----------
    ; DIV entre 100 separa pesos (EAX) y centavos (EDX).
escribirDinero:
    mov centavosMostrados, eax
    mov al, '$'
    call WriteChar
    mov eax, centavosMostrados
    mov edx, 0
    mov ebx, 100
    div ebx
    mov centavosMostrados, edx      ; los centavos se muestran despues
    mov numeroMostrado, 1
    jmp convertirNumero             ; escribe los pesos y regresa a mostrarCentavos

mostrarCentavos:
    mov al, '.'
    call WriteChar
    mov eax, centavosMostrados
    mov edx, 0
    mov ebx, 10
    div ebx                         ; EAX = decenas, EDX = unidades
    add al, '0'
    call WriteChar
    mov al, dl
    add al, '0'
    call WriteChar                  ; siempre 2 digitos: 5 se ve como 05
    mov edx, OFFSET msgMoneda
    call WriteString

    cmp regresoDinero, 1
    je regresoTabla                 ; era un precio de la tabla
    cmp regresoDinero, 3
    je resumenIngresos              ; era el valor del inventario
    cmp regresoDinero, 4
    je resumenFin                   ; eran los ingresos de la sesion
    call Crlf                       ; era el total de una venta: muestra el
    jmp mostrarUnProducto           ; producto con su nueva existencia

    ; ==================================================================
    ; OPCION 3: BUSCAR POR CODIGO
    ; Usa la misma captura y busqueda de pedirCodigo; si el codigo existe
    ; salta a mostrarUnProducto.
    ; ==================================================================
buscarPorCodigo:
    mov accion, ACCION_BUSCAR
    jmp pedirCodigo

mostrarUnProducto:
    mov ecx, 1                      ; ESI ya apunta al registro encontrado
    jmp imprimirTabla

    ; ==================================================================
    ; OPCION 2 DEL MENU PRINCIPAL: RECIBIR MERCANCIA
    ; Pide el codigo (misma captura y busqueda de pedirCodigo), luego la
    ; cantidad, y suma a la existencia solo si el total no pasa de 100.
    ; ==================================================================
recibirMercancia:
    mov accion, ACCION_RECIBIR
    cmp numProductos, 0
    jne pedirCodigo
    mov edx, OFFSET msgInventarioVacio
    jmp mostrarError

pedirCantidad:
    mov direccionRegistro, esi      ; se guarda porque ESI se vuelve a usar
    mov edx, OFFSET msgPedirCantidad
    call WriteString
    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString
    cmp eax, 1
    jb errorDatoInvalido            ; vacia
    cmp eax, 3
    ja errorDatoInvalido            ; mas de 3 caracteres

    mov ecx, eax                    ; ECX = caracteres a revisar
    mov esi, OFFSET textoIngresado
    mov eax, 0
cantidadDigitos:
    movzx ebx, BYTE PTR [esi]
    cmp bl, '0'
    jb errorDatoInvalido
    cmp bl, '9'
    ja errorDatoInvalido
    sub bl, '0'
    imul eax, 10                    ; resultado = resultado * 10 + digito
    add eax, ebx
    inc esi
    loop cantidadDigitos
    cmp eax, 1
    jb errorDatoInvalido            ; la cantidad minima es 1
    cmp eax, 100
    ja errorDatoInvalido

    mov esi, direccionRegistro
    cmp accion, ACCION_VENDER
    je venderProducto               ; vender sigue mas abajo
    add eax, [esi + OFF_EXISTENCIA] ; EAX = existencia actual + cantidad
    cmp eax, 100
    ja errorExcedeCapacidad         ; pasaria de 100: no se recibe nada
    mov [esi + OFF_EXISTENCIA], eax
    mov cambiosSinGuardar, 1

    mov edx, OFFSET msgMercanciaRecibida
    call WriteString
    jmp mostrarUnProducto           ; muestra el producto con su nueva existencia

    ; ==================================================================
    ; OPCION 3 DEL MENU PRINCIPAL: VENDER
    ; Pide el codigo y la cantidad (pedirCodigo y pedirCantidad), y vende
    ; solo si hay existencia suficiente. 
    ; ==================================================================
venderJuego:
    mov accion, ACCION_VENDER
    cmp numProductos, 0
    jne pedirCodigo
    mov edx, OFFSET msgInventarioVacio
    jmp mostrarError

    ; Entrada: ESI = registro del producto, EAX = cantidad (1 a 100)
venderProducto:
    mov cantidadVenta, eax
    cmp eax, [esi + OFF_EXISTENCIA]
    ja errorSinExistencia           ; piden mas unidades de las que hay

    ; Importe = precio * cantidad (si EDX no es 0, no cabe en 32 bits)
    mov eax, [esi + OFF_PRECIO]
    mov ebx, cantidadVenta
    mul ebx
    cmp edx, 0
    jne errorDesbordamiento
    mov importeVenta, eax

    ; Ingresos de la sesion + esta venta (CF = 1 si se desborda)
    mov eax, ingresosSesion
    add eax, importeVenta
    jc errorDesbordamiento

    ; ---------- Todo es valido: ahora si se modifican los datos ----------
    mov ingresosSesion, eax
    mov ebx, cantidadVenta
    sub [esi + OFF_EXISTENCIA], ebx
    mov cambiosSinGuardar, 1

    mov edx, OFFSET msgVentaRealizada
    call WriteString
    mov eax, importeVenta
    mov regresoDinero, 2
    jmp escribirDinero              ; escribe el total y muestra el producto

    ; ==================================================================
    ; OPCION 4 DEL MENU PRINCIPAL: MOSTRAR RESUMEN
    ; ESI recorre el catalogo sumando las unidades y el valor del inventario
    ; ==================================================================
mostrarResumen:
    mov accion, ACCION_RESUMEN
    mov unidadesTotales, 0
    mov valorInventario, 0
    mov esi, OFFSET catalogo        ; ESI = primer registro
    mov ecx, numProductos
    cmp ecx, 0
    je resumenEscribir              ; sin productos: todo queda en 0
resumenCiclo:
    mov eax, [esi + OFF_EXISTENCIA]
    add unidadesTotales, eax
    mov ebx, [esi + OFF_PRECIO]
    mul ebx                         ; EDX:EAX = existencia * precio
    cmp edx, 0
    jne errorDesbordamiento
    add valorInventario, eax
    jc errorDesbordamiento          ; CF = 1: la suma no cabe en 32 bits
    add esi, TAM_REGISTRO           ; siguiente registro
    loop resumenCiclo

    ; Cada numero se escribe con convertirNumero o escribirDinero, que
    ; regresan a la siguiente etiqueta (resumenValor, resumenIngresos, resumenFin).
resumenEscribir:
    mov edx, OFFSET msgResumenTitulo
    call WriteString
    mov edx, OFFSET msgResumenUnidades
    call WriteString
    mov eax, unidadesTotales
    mov numeroMostrado, 3
    jmp convertirNumero             ; escribe las unidades y regresa a resumenValor

resumenValor:
    call Crlf
    mov edx, OFFSET msgResumenValor
    call WriteString
    mov eax, valorInventario
    mov regresoDinero, 3
    jmp escribirDinero              ; escribe el valor y regresa a resumenIngresos

resumenIngresos:
    call Crlf
    mov edx, OFFSET msgResumenIngresos
    call WriteString
    mov eax, ingresosSesion
    mov regresoDinero, 4
    jmp escribirDinero              ; escribe los ingresos y regresa a resumenFin

resumenFin:
    call Crlf
    jmp menuPrincipal

    ; ==================================================================
    ; OPCION 6 DEL MENU PRINCIPAL: REGLA DEL NEGOCIO
    ; Alerta de existencia minima: se aplica a los productos con menos de
    ; MIN_EXISTENCIA unidades. Primero cuenta cuantos son; si hay alguno,
    ; muestra la tabla solo con esos (tablaFila se salta los demas).
    ; ==================================================================
reglaAlertas:
    mov accion, ACCION_REGLA
    cmp numProductos, 0
    jne reglaContar
    mov edx, OFFSET msgInventarioVacio
    jmp mostrarError
reglaContar:
    mov esi, OFFSET catalogo        ; ESI = primer registro
    mov ecx, numProductos
    mov ebx, 0                      ; EBX = productos en alerta
reglaCiclo:
    cmp DWORD PTR [esi + OFF_EXISTENCIA], MIN_EXISTENCIA
    jae reglaSiguiente
    inc ebx                         ; existencia menor al minimo
reglaSiguiente:
    add esi, TAM_REGISTRO
    loop reglaCiclo

    cmp ebx, 0
    jne reglaMostrar
    mov edx, OFFSET msgSinAlertas   ; ninguno en alerta
    jmp mostrarError
reglaMostrar:
    mov edx, OFFSET msgAlertaTitulo
    call WriteString
    mov esi, OFFSET catalogo
    mov ecx, numProductos
    jmp imprimirTabla               ; la tabla filtra segun accion

    ; ==================================================================
    ; SUBMENU 5: GUARDAR Y CARGAR
    ; ==================================================================
menuArchivo:
    mov accion, ACCION_ARCHIVO
    mov edx, OFFSET msgMenuArchivo
    call WriteString

    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString

    cmp eax, 1
    jne opcionInvalidaArchivo
    mov al, textoIngresado
    cmp al, '0'
    jb opcionInvalidaArchivo
    cmp al, '2'
    ja opcionInvalidaArchivo

    cmp al, '0'
    je menuPrincipal                ; 0 = volver al menu principal
    cmp al, '1'
    je guardarCatalogo
    jmp cargarCatalogo              ; opcion 2

opcionInvalidaArchivo:
    mov edx, OFFSET msgOpcionInvalida
    call WriteString
    jmp menuArchivo

    ; ==================================================================
    ; GUARDAR CATALOGO
    ; Primero arma el texto en bufferArchivo.
    ; ESI recorre los registros y EDI es donde se va escribiendo el texto.
    ; Despues crea el archivo y escribe el texto de una sola vez.
    ; ==================================================================
guardarCatalogo:
    mov edi, OFFSET bufferArchivo
    mov esi, OFFSET catalogo
    mov eax, numProductos
    mov registrosPendientes, eax
    cmp eax, 0
    je guardarEscribir              ; sin productos: el archivo queda vacio

guardarRegistro:
    mov ebx, esi                    ; EBX = donde empieza el codigo
guardarCodigo:
    mov al, [ebx]
    cmp al, 0
    je guardarBarra1                ; llego al 00h: termino el codigo
    mov [edi], al
    inc ebx
    inc edi
    jmp guardarCodigo
guardarBarra1:
    mov BYTE PTR [edi], '|'
    inc edi

    mov ebx, esi
    add ebx, OFF_NOMBRE             ; EBX = donde empieza el nombre
guardarNombre:
    mov al, [ebx]
    cmp al, 0
    je guardarBarra2
    mov [edi], al
    inc ebx
    inc edi
    jmp guardarNombre
guardarBarra2:
    mov BYTE PTR [edi], '|'
    inc edi

    mov eax, [esi + OFF_PRECIO]     ; precio en centavos
    mov retornoNumero, 1
    jmp numeroAMemoria              ; escribe el numero y regresa a guardarBarra3

guardarBarra3:
    mov BYTE PTR [edi], '|'
    inc edi
    mov eax, [esi + OFF_EXISTENCIA]
    mov retornoNumero, 2
    jmp numeroAMemoria              ; escribe el numero y regresa a guardarFinLinea

guardarFinLinea:
    mov BYTE PTR [edi], 0Dh         ; fin de linea (salto de linea de Windows)
    inc edi
    mov BYTE PTR [edi], 0Ah
    inc edi
    add esi, TAM_REGISTRO           ; siguiente registro
    dec registrosPendientes
    jnz guardarRegistro

guardarEscribir:
    mov eax, edi
    sub eax, OFFSET bufferArchivo
    mov bytesPedidos, eax           ; bytes de texto que se armaron

    mov edx, OFFSET nombreArchivo
    call CreateOutputFile           ; EAX = handle
    cmp eax, INVALID_HANDLE_VALUE
    je errorCrearArchivo
    mov manejadorArchivo, eax

    mov eax, manejadorArchivo
    mov edx, OFFSET bufferArchivo
    mov ecx, bytesPedidos
    call WriteToFile                ; EAX = bytes realmente escritos
    cmp eax, bytesPedidos
    jne guardarFallo                ; no se escribio todo

    mov eax, manejadorArchivo
    call CloseFile
    mov cambiosSinGuardar, 0
    mov edx, OFFSET msgGuardado
    call WriteString
    jmp menuArchivo

guardarFallo:
    mov eax, manejadorArchivo
    call CloseFile                  ; se cierra el archivo aunque haya fallado
    mov edx, OFFSET msgErrorEscribir
    jmp mostrarError

errorCrearArchivo:
    mov edx, OFFSET msgErrorCrear
    jmp mostrarError

    ; ---------- Convertir un numero a texto dentro del buffer ----------
    ; Igual que convertirNumero, pero en lugar de mostrar cada digito lo
    ; escribe en [EDI] y avanza EDI.
    ; Entrada: EAX = numero, retornoNumero = 1 (precio) o 2 (existencia)
numeroAMemoria:
    mov ebx, 10
    mov ecx, 0                      ; ECX cuenta los digitos
numExtraer:
    mov edx, 0
    div ebx                         ; EDX = digito, EAX = lo que falta
    push edx
    inc ecx
    cmp eax, 0
    jne numExtraer
numEscribir:
    pop eax
    add al, '0'
    mov [edi], al
    inc edi
    dec ecx
    jnz numEscribir

    cmp retornoNumero, 1
    je guardarBarra3                ; ya escribio el precio
    jmp guardarFinLinea             ; ya escribio la existencia

    ; ==================================================================
    ; CARGAR CATALOGO
    ; Lee el archivo a bufferArchivo y va armando los registros en
    ; catalogoNuevo. Solo si TODAS las lineas son validas se copia al
    ; catalogo; si algo falla, el catalogo no cambia.
    ; ==================================================================
cargarCatalogo:
    mov edx, OFFSET nombreArchivo
    call OpenInputFile              ; EAX = handle
    cmp eax, INVALID_HANDLE_VALUE
    je errorArchivoNoExiste
    mov manejadorArchivo, eax

    mov edx, OFFSET bufferArchivo
    mov ecx, TAM_BUFFER_ARCHIVO - 1 ; deja 1 byte para el 00h
    call ReadFromFile               ; EAX = bytes leidos, CF = 1 si hubo error
    mov bytesLeidos, eax            ; MOV no cambia CF
    jc cargaFalloLectura

    mov eax, manejadorArchivo
    call CloseFile
    mov esi, OFFSET bufferArchivo
    add esi, bytesLeidos
    mov BYTE PTR [esi], 0           ; 00h despues del ultimo byte leido

    cmp bytesLeidos, 480
    ja errorArchivoInvalido         ; mas grande que cualquier inventario valido

    mov conteoNuevo, 0
    mov esi, OFFSET bufferArchivo   ; ESI recorre el texto del archivo

    ; ---------- Una vuelta por linea ----------
cargaLinea:
    mov al, [esi]
    cmp al, 0
    je cargaCopiar                  ; fin del texto: todo salio bien
    cmp al, 0Dh
    je cargaSaltar                  ; las lineas en blanco se ignoran
    cmp al, 0Ah
    je cargaSaltar
    cmp conteoNuevo, MAX_PRODUCTOS
    jae errorArchivoInvalido        ; hay mas de 10 productos

    mov eax, conteoNuevo            ; registro nuevo = catalogoNuevo + conteoNuevo * 44
    mov ebx, TAM_REGISTRO
    mul ebx
    add eax, OFFSET catalogoNuevo
    mov direccionRegistro, eax
    mov edi, eax

    ; Codigo: exactamente 7 caracteres antes del |
    mov ecx, 0
cargaCodigo:
    mov al, [esi]
    cmp al, '|'
    je cargaCodigoFin
    cmp al, ' '
    jb errorArchivoInvalido         ; fin de linea o de texto antes de tiempo
    cmp ecx, 7
    jae errorArchivoInvalido        ; mas de 7 caracteres
    mov [edi], al
    inc edi
    inc esi
    inc ecx
    jmp cargaCodigo
cargaCodigoFin:
    cmp ecx, 7
    jne errorArchivoInvalido        ; menos de 7 caracteres
    mov BYTE PTR [edi], 0           ; 00h al final del codigo
    inc esi                         ; salta el |

    ; Nombre: de 1 a 25 caracteres antes del |
    mov edi, direccionRegistro
    add edi, OFF_NOMBRE
    mov ecx, 0
cargaNombre:
    mov al, [esi]
    cmp al, '|'
    je cargaNombreFin
    cmp al, ' '
    jb errorArchivoInvalido
    cmp ecx, 25
    jae errorArchivoInvalido        ; mas de 25 caracteres
    mov [edi], al
    inc edi
    inc esi
    inc ecx
    jmp cargaNombre
cargaNombreFin:
    cmp ecx, 1
    jb errorArchivoInvalido         ; nombre vacio
    mov BYTE PTR [edi], 0           ; 00h al final del nombre
    inc esi

    ; Precio: solo digitos (centavos), de 1 a 999999
    mov eax, 0
    mov ecx, 0                      ; ECX = digitos leidos
cargaPrecio:
    movzx ebx, BYTE PTR [esi]
    cmp bl, '|'
    je cargaPrecioFin
    cmp bl, '0'
    jb errorArchivoInvalido
    cmp bl, '9'
    ja errorArchivoInvalido
    cmp ecx, 6
    jae errorArchivoInvalido        ; mas de 6 digitos
    sub bl, '0'
    imul eax, 10                    ; resultado = resultado * 10 + digito
    add eax, ebx
    inc ecx
    inc esi
    jmp cargaPrecio
cargaPrecioFin:
    cmp ecx, 0
    je errorArchivoInvalido         ; precio vacio
    cmp eax, 1
    jb errorArchivoInvalido
    cmp eax, 999999
    ja errorArchivoInvalido         ; precio fuera de rango
    mov edi, direccionRegistro
    mov [edi + OFF_PRECIO], eax
    inc esi

    ; Existencia: solo digitos, de 0 a 100, hasta el fin de la linea
    mov eax, 0
    mov ecx, 0
cargaExistencia:
    movzx ebx, BYTE PTR [esi]
    cmp bl, 0Dh
    je cargaExistenciaFin
    cmp bl, 0Ah
    je cargaExistenciaFin
    cmp bl, 0
    je cargaExistenciaFin
    cmp bl, '0'
    jb errorArchivoInvalido
    cmp bl, '9'
    ja errorArchivoInvalido
    cmp ecx, 3
    jae errorArchivoInvalido        ; mas de 3 digitos
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc ecx
    inc esi
    jmp cargaExistencia
cargaExistenciaFin:
    cmp ecx, 0
    je errorArchivoInvalido         ; existencia vacia
    cmp eax, 100
    ja errorArchivoInvalido         ; existencia fuera de rango
    mov edi, direccionRegistro
    mov [edi + OFF_EXISTENCIA], eax
    inc conteoNuevo                 ; esta linea ya es un producto del catalogo nuevo
    jmp cargaLinea

cargaSaltar:
    inc esi
    jmp cargaLinea

    ; ---------- Todo es valido: ahora si reemplaza el catalogo ----------
cargaCopiar:
    mov esi, OFFSET catalogoNuevo
    mov edi, OFFSET catalogo
    mov ecx, conteoNuevo
    imul ecx, TAM_REGISTRO          ; ECX = bytes por copiar
    cmp ecx, 0
    je cargaListo                   ; archivo vacio: no hay nada que copiar
copiarCatalogo:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec ecx
    jnz copiarCatalogo
cargaListo:
    mov eax, conteoNuevo
    mov numProductos, eax
    mov cambiosSinGuardar, 0
    mov edx, OFFSET msgCargado
    call WriteString
    jmp menuArchivo

cargaFalloLectura:
    mov eax, manejadorArchivo
    call CloseFile
errorArchivoInvalido:
    mov edx, OFFSET msgArchivoInvalido
    jmp mostrarError

errorArchivoNoExiste:
    mov edx, OFFSET msgArchivoNoExiste
    jmp mostrarError

    ; ==================================================================
    ; SALIR
    ; Si hay cambios sin guardar avisa y pregunta si de verdad quiere salir.
    ; ==================================================================
salir:
    cmp cambiosSinGuardar, 0
    je despedida
    mov edx, OFFSET msgAvisoSalir
    call WriteString
    mov edx, OFFSET textoIngresado
    mov ecx, 79
    call ReadString
    cmp eax, 1
    jne menuPrincipal               ; respuesta distinta de un caracter: no sale
    mov al, textoIngresado
    cmp al, 'S'
    je despedida
    cmp al, 's'
    je despedida
    jmp menuPrincipal               ; cualquier otra respuesta: sigue en el programa

despedida:
    mov edx, OFFSET msgDespedida
    call WriteString
    exit
main ENDP

END main