
import escenografiaJuego.*
import wollok.game.*
import wollok.game.*

class Camino inherits List{//decimos que un camino es una lista de baldosas no que tiene una lista de estas
	const direccionescaminosAdyacentes
	const direccionPropia
	const posicion
	
	method esMiPosicion(posicion_) = posicion.iguales(posicion_)
	method darDireccion(baldosa_) = self.get(baldosa_).direccion()
	method crearBaldosa(posicion_,direcciones_)=new BaldosaFlecha(direcciones = direcciones_, image = "celda.png", posicion = posicion_)
	method construirCamino(largoDelCamino){
		(largoDelCamino-1).times({
			i => self.add(self.crearBaldosa(posicion.sumarVectorEscalado(direccionPropia,i-1),[direccionPropia]))
		})
		self.add(self.crearBaldosa(posicion.sumarVectorEscalado(direccionPropia,largoDelCamino-1),direccionescaminosAdyacentes))
		self.forEach({baldosa => game.addVisual(baldosa)})
	}
	method estaEnElCamino(punto){
		const vectorDistancia = posicion.vectorHaciaPunto(punto)
		const vectorLongitud = direccionPropia.multiplicar(self.size()-1)
		return vectorDistancia.esSubVectorDe(vectorLongitud) or posicion.iguales(punto)
	}
}

object cabezal{
    var property image = "cabezalArriba.png"
    var property position = game.center() 
	var direccionTorre = new Vector( x =0, y= 1 )
	var estaRedireccionandoTorre = false
	
	method impactar(bala){}
    method moverseHaciaArriba(){
    	if ( position.y() < game.height() - 1 and estaRedireccionandoTorre.negate()){
    		self.position(position.up(1))
    	}
    }
    method moverseHaciaAbajo(){
    	if ( position.y() > 0 and estaRedireccionandoTorre.negate()){
    		self.position(position.down(1))
    	}
    }
    method moverseHaciaIzquierda(){
    	if ( position.x() > 0 and estaRedireccionandoTorre.negate()){
    		self.position(position.left(1))
    	}
    }
    method moverseHaciaDerecha(){
    	if ( position.x() < game.width() - 1 and estaRedireccionandoTorre.negate()){
    		self.position(position.right(1))
    	}
    }
    
    method estoyEncimaDeUnaTorre() = controlador.posicionDeTorreExistente(self.posAVector())
    method cambiarEstado() { estaRedireccionandoTorre = estaRedireccionandoTorre.negate() }
    method redireccionarTorre() {
    	controlador.darTorre(self.posAVector()).direccion(direccionTorre)
    }
    
    method girarTorreSentidoAntiHorario(){ 
    	direccionTorre = direccionTorre.rotar90grados()
    	image = "cabezal"+direccionTorre.vectorAString()+".png"
    	if ( estaRedireccionandoTorre ){
    		self.redireccionarTorre()
    	}
    }
    method posAVector() = new Vector(x=position.x(),y=position.y())
    method girarTorreSentidoHorario(){ 
    	direccionTorre = direccionTorre.rotar90grados().multiplicar(-1)
    	image = "cabezal"+direccionTorre.vectorAString()+".png"
    	if ( estaRedireccionandoTorre ){
    		self.redireccionarTorre()
    	}
    }
    method colocarTorre(){
    	if (controlador.estaEnUnCamino(position).negate() and controlador.posicionDeTorreExistente(self.posAVector()).negate()){
    		controlador.agregarTorre(new Vector(x=position.x(),y=position.y()),direccionTorre)
    	}
    }
    
}

//El controlador se encarga de todo el tema de poner y sacar objetos los demas objetos solo le pediran que lo haga por ellos 
object controlador {
	//no hay razon para que otros objetos puedan tocar las listas a si que las dejamos sin property
    const torres = []
    const enemigos = []
    const proyectiles = []
    const listaDeCaminos = []
    var numeroDeSpawners = 0
    var vidaDelJugador = 3
//  var property debeDispararDerecha = initialValue
	
	
	method darTorre(posicion_){ return torres.find({torre => torre.esMiPosicion(posicion_)})}
	method abranFuego() { torres.forEach{torre => torre.disparar()} }
	method reducirVida() {
		vidaDelJugador -= 1
		if ( vidaDelJugador == 0 ){//Preguntar por que si pongo < 1 en ves de un valor exacto el juego crashea
			self.finDePartida()
		}
	}
  	method limpiarPantalla() {
  		game.clear()//eliminamos todo de la pantalla
  		enemigos.clear()
  		proyectiles.clear()
  		torres.clear()
  		listaDeCaminos.clear()
  	}
  	method finDePartida(){
  		game.removeTickEvent("moverObjetos")
  		game.removeTickEvent("disparoDeTorres")
  		numeroDeSpawners.times({i => game.removeTickEvent(  "spawner numero " + i.toString() ) })
  		game.schedule(3000,
  			{ 
  				self.limpiarPantalla()
  				//cambiaremos por la pantalla de fin
  				if ( vidaDelJugador <= 0 ){//En caso de perder
  				
  					game.addVisual(new ObjetoDeJuego(posicion = self.vector(10,7) , image = "perdiste.png" )) 
  					
  				}else {//en caso de ganar
  				
  					game.addVisual(new ObjetoDeJuego(posicion = self.vector(10,7) , image = "ganaste.png" )) 	
  				}
  			}
  		)//retiramos todo objeto de la pantalla
  	}
  	method agregarSpawner(tiempo , posicion , vida){
  		numeroDeSpawners += 1
  		game.onTick(tiempo, "spawner numero " + numeroDeSpawners.toString() , {self.agregarEnemigo(vida, "matias.png", posicion)})	
  	}
  	method asignarCamino(posicion) = listaDeCaminos.find({camino => camino.esMiPosicion(posicion)})
  	method instanciarEnemigo(vida_,imagen_,posicion_) = new Enemigo(vida = vida_, image = imagen_, posicion = posicion_, camino = self.asignarCamino(posicion_))
  	method agregarEnemigo(vida_,imagen_,posicion_){ 
  		const enemigo = self.instanciarEnemigo(vida_, imagen_, posicion_)
  		enemigos.add(enemigo)
  		game.addVisual(enemigo)
  	}
  	method retirarEnemigo(enemigo){
    	game.removeVisual(enemigo)
    	enemigos.remove(enemigo)
    	self.reducirVida()
    }
    method moverEnemigos(){enemigos.forEach({enemigo => enemigo.moverse()})}
    method moverBalas(){proyectiles.forEach({bala => bala.moverse()})} 
  	method instancearTorre(posicion_,direccion_) = new Torre(objetivo = null, image = "torrePrueba.png", posicion = posicion_,direccion = direccion_)
  	method agregarTorre(posicion_,direccion_){
    	const torre = self.instancearTorre(posicion_,direccion_)
        torres.add( torre )
        game.addVisual( torre )
    }
    method agregarCamino(direccionesSiguientesCaminos_,direccionPropia_,posicion_,largo_){
    	const camino_ = new Camino(direccionescaminosAdyacentes = direccionesSiguientesCaminos_, direccionPropia = direccionPropia_, posicion = posicion_)
    	camino_.construirCamino(largo_)
    	listaDeCaminos.add(camino_)
    }
    
    method posicionDeTorreExistente(posicion_) = torres.any({torre => torre.esMiPosicion(posicion_)})
    
    method vector(x_,y_) = new Vector(x=x_,y=y_)
    method estaEnUnCamino(posicion) = listaDeCaminos.any({camino => camino.estaEnElCamino(posicion)})
 
	
	method instanciarProyectil(posicion_,direccion_,imagen_) = new Proyectil(direccion = direccion_, image = imagen_, posicion = posicion_)
	method agregarPoryectil(posicion_,direccion_,imagen_){
		const proyectil = self.instanciarProyectil(posicion_, direccion_,imagen_)
		proyectiles.add(proyectil)
		game.addVisual(proyectil)
		game.onCollideDo(proyectil, {enemigo => enemigo.impactar(proyectil)})
	}
	method removerProjectil(projectil){
		game.removeVisual(projectil)
		proyectiles.remove(projectil)
	}
}
