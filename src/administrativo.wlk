
import escenografiaJuego.*
import wollok.game.*
import wollok.game.*


object interfazUsuario{
	var dineroDelJugador = 40
    var vidaDelJugador = 3
    method position() = instanciador.vector(15, 14)
	method reducirVida() {
		vidaDelJugador -= 1
		if ( vidaDelJugador == 0 ){//Preguntar por que si pongo < 1 en ves de un valor exacto el juego crashea
			controlador.finDePartida()
		}
	}
	method elJugadorMurio() = vidaDelJugador==0
	method dineroDelJugador(dinero_){
		dineroDelJugador = dineroDelJugador + dinero_
	} 
	method reducirDineroDelJugador(dinero_) {dineroDelJugador -= dinero_}
	method puedoComprar(costo_)=dineroDelJugador-costo_ >= 0
	
	method text() = "Vida: " + vidaDelJugador + "      dinero = $" + dineroDelJugador 
	method textColor() = "#C0C0C0"
}

object cabezal{
    var property image = "cabezalArriba.png"
    var property position = instanciador.vector(10,7)
	var direccion = arriba
	method impactar(bala){}
    method colocarTorre(){
    	if (self.posicionLibre() and interfazUsuario.puedoComprar(10)){
    		controlador.agregarTorre(new Vector(x=position.x(),y=position.y()),direccion)
    		interfazUsuario.reducirDineroDelJugador(10)
    	}
    }
    method moverseHaciaArriba(){
    	if ( position.y() < game.height() - 1 ){
    		self.position(position.sumar(arriba))
    	}
    }
    method moverseHaciaAbajo(){
    	if ( position.y() > 0 ){
    		self.position(position.sumar(abajo))
    	}
    }
    method moverseHaciaIzquierda(){
    	if ( position.x() > 0 ){
    		self.position(position.sumar(izquierda))
    	}
    }
    method moverseHaciaDerecha(){
    	if ( position.x() < game.width() - 1 ){
    		self.position(position.sumar(derecha))
    	}
    }
    method redireccionarTorre() {
    	game.colliders(self).forEach{objeto_ => objeto_.alinear(direccion)}
    }
    method rotar(sentido_){ 
    	direccion = direccion.rotar90grados().multiplicar(sentido_)
    	image = "cabezal"+direccion.vectorAString()+".png"
    	self.redireccionarTorre()
    	
    }
    method posicionLibre()= game.colliders(self).any{objeto => objeto.position().iguales(self.position())}.negate()
}

object instanciador {
	method baldosa(posicion_,direccion_) = new BaldosaFlecha(direccion = direccion_, image = "celda.png", posicion = posicion_)
	method baldosaFinal(posicion_) = new BaldosaFinal(image = "celda.png", posicion = posicion_)
	method baldosaInterseccion(posicion_) = new BaldosaInterseccion(image = "celda.png", posicion = posicion_)
	method baldosaCuracion(posicion_,direccion_) = new BaldosaCuracion(direccion = direccion_, image = "baldosaCuracion.png", posicion = posicion_)
	method vector(x_,y_) = new Vector(x=x_,y=y_)
	method instanciarProyectil(posicion_,direccion_,imagen_) = new Proyectil(direccion = direccion_, image = imagen_, posicion = posicion_)
	method instanciarEnemigo(vida_,imagen_,posicion_) = new Enemigo(vida = vida_, image = imagen_, posicion = posicion_,direccion = vectorNulo)
	method instancearTorre(posicion_,direccion_) = new Torre(objetivo = null, image = "torre" +direccion_.vectorAString()+ ".png", posicion = posicion_,direccion = direccion_)
}

object audio{
	const property musicaInicio = game.sound("musicaInicio.mp3") // Musica agregada 
    const property musicaGameplay = game.sound("musicaGameplay.mp3")
    const property musicaPerder = game.sound("musicaPerder.mp3")
    const property musicaVictoria = game.sound("musicaVictoria.mp3")
}


//El controlador se encarga de todo el tema de poner y sacar objetos los demas objetos solo le pediran que lo haga por ellos 
object controlador {
	//no hay razon para que otros objetos puedan tocar las listas a si que las dejamos sin property
    const torres = new Set()
    const enemigos = new Set()
    const proyectiles = new Set()
    const baldosas = new Set()
    var numeroDeSpawners = 0
    
//  var property debeDispararDerecha = initialValue
	
	
	method darTorre(posicion_){ return torres.find({torre => torre.esMiPosicion(posicion_)})}
	method abranFuego() { torres.forEach{torre => torre.disparar()} }
  	method limpiarPantalla() {
  		game.clear()//eliminamos todo de la pantalla
  		
  	}
  	method finDePartida(){
  		game.removeTickEvent("moverObjetos")
  		game.removeTickEvent("moverEnemigos")
  		game.removeTickEvent("disparoDeTorres")
  		numeroDeSpawners.times({i => game.removeTickEvent(  "spawner numero " + i.toString() ) })
  		game.schedule(3000,
  			{ 
  				self.limpiarPantalla()
  				//cambiaremos por la pantalla de fin
  				if ( interfazUsuario.elJugadorMurio() ){//En caso de perder
  				
  					game.addVisual(new ObjetoDeJuego(posicion = instanciador.vector(2,0) , image = "perdiste.png" ))
  					audio.musicaGameplay().stop()
  					audio.musicaPerder().play() 
  					
  				}else {//en caso de ganar
  				
  					game.addVisual(new ObjetoDeJuego(posicion = instanciador.vector(2,1) , image = "ganaste.png" )) 
  					audio.musicaGameplay().stop()
  					audio.musicaVictoria().play()	
  				}
  			}
  		)//retiramos todo objeto de la pantalla
  	}
  	
  	
	method camino() = baldosas
    method moverEnemigos(){enemigos.forEach({enemigo => enemigo.moverse()})}
    method moverBalas(){proyectiles.forEach({bala => bala.moverse()})} 
  	
  	method agregarSpawner(tiempo , posicion , vida, imagen){
  		numeroDeSpawners += 1
  		game.onTick(tiempo, "spawner numero " + numeroDeSpawners.toString() , {self.agregarEnemigo(vida, imagen, posicion)})	
  	}
  	method agregarTorre(posicion_,direccion_){
    	const torre = instanciador.instancearTorre(posicion_,direccion_)
        torres.add( torre )
        game.addVisual( torre )
    }
    method agregarRecta(posicion_,direccion_,largo_){//los caminos sera una serie de baldosas normales
    	largo_.times({
    		i => const baldosa = instanciador.baldosa(posicion_.sumarVectorEscalado(direccion_,i-1),direccion_)
    		baldosas.add(baldosa)
    		game.addVisual(baldosa)}
    	)
    }
  	method agregarEnemigo(vida_,imagen_,posicion_){ 
  		const enemigo = instanciador.instanciarEnemigo(vida_, imagen_, posicion_)
  		enemigos.add(enemigo)
  		game.addVisual(enemigo)
  	}
    method agregarBaldosa(baldosa_){
    	baldosas.add(baldosa_)
    	game.addVisual(baldosa_)
    }
	method agregarPoryectil(posicion_,direccion_,imagen_){
		const proyectil = instanciador.instanciarProyectil(posicion_, direccion_,imagen_)
		proyectiles.add(proyectil)
		game.addVisual(proyectil)
		game.onCollideDo(proyectil, {enemigo => enemigo.impactar(proyectil)})
	}	
  	method retirarEnemigo(enemigo){
    	game.removeVisual(enemigo)
    	enemigos.remove(enemigo)
    }
	method removerProjectil(projectil){
		game.removeVisual(projectil)
		proyectiles.remove(projectil)
	}
}


