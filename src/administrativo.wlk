
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
}

object cabezal{
    var property image = "cabezal.png"
    var property position = game.center() 
	var direccionTorre = new Vector( x =0, y= 1 )
	
	
    method moverseHaciaArriba(){
        self.position(position.up(1))
    }
    method moverseHaciaAbajo(){
        self.position(position.down(1))
    }
    method moverseHaciaIzquierda(){
        self.position(position.left(1))
    }
    method moverseHaciaDerecha(){
        self.position(position.right(1))
    }
    
    method girarTorreSentidoAntiHorario(){ direccionTorre = direccionTorre.rotar90grados() }
    method girarTorreSentidoHorario(){ direccionTorre = direccionTorre.rotar90grados().multiplicar(-1) }
    method colocarTorre(){controlador.agregarTorre(new Vector(x=position.x(),y=position.y()),direccionTorre)}
    
    //method hayUnaTorrePresente() = //devolvera true si en la lista de torres existe una que tenga la misma posicion que el cabezal 
}

//El controlador se encarga de todo el tema de poner y sacar objetos los demas objetos solo le pediran que lo haga por ellos 
object controlador {
	//no hay razon para que otros objetos puedan tocar las listas a si que las dejamos sin property
    const torres = []
    const objetosMobibles = []
    const listaDeCaminos = []
    var numeroDeSpawners = 0
    var vidaDelJugador = 300
//  var property debeDispararDerecha = initialValue
	
	method abranFuego() { torres.forEach{torre => torre.disparar()} }
	method reducirVida() {
		vidaDelJugador -= 1
		if ( vidaDelJugador == 0 ){//Preguntar por que si pongo < 1 en ves de un valor exacto el juego crashea
			self.finDePartida()
		}
	}
  	method limpiarPantalla() {
  		game.clear()//eliminamos todo de la pantalla
  		objetosMobibles.clear()
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
  				if ( vidaDelJugador == 0 ){//En caso de perder
  					
  				}else {//en caso de ganar
  					
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
  		objetosMobibles.add(enemigo)
  		game.addVisual(enemigo)
  	}
  	method retirarEnemigo(enemigo){ 
    	game.removeVisual(enemigo) 
    	objetosMobibles.remove(enemigo)
    	self.reducirVida()
    }
    method moverObjetos(){objetosMobibles.forEach({enemigo => enemigo.moverse()})}
    //method moverBalas(){objetosMobibles.forEach({bala => bala.mover()})}
    //method disparar(){torres.forEach({torre => torre.disparar()})}
    //cambiar esto luego ( en caso de la alternativa sea aceptada ) 
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
    method vector(x_,y_) = new Vector(x=x_,y=y_)
    
    method debeDispararArriba(vector) = objetosMobibles.any{enemigo => enemigo.position().x() == vector.x() and enemigo.position().y() > vector.y()}
  	method debeDispararAbajo(vector) = objetosMobibles.any{enemigo => enemigo.position().x() == vector.x() and enemigo.position().y() < vector.y()}
	method debeDispararIzquierda(vector) = objetosMobibles.any{enemigo => enemigo.position().x() == vector.y() and enemigo.position().y() > vector.y()}
	method debeDispararDerecha(vector) = objetosMobibles.fany{enemigo => enemigo.position().x() == vector.y() and enemigo.position().y() < vector.y()}
	
	method instanciarProyectil(posicion_,direccion_,imagen_) = new Proyectil(direccion = direccion_, image = imagen_, posicion = posicion_)
	method agregarPoryectil(posicion_,direccion_,imagen_){
		const proyectil = self.instanciarProyectil(posicion_, direccion_,imagen_)
		objetosMobibles.add(proyectil)
		game.addVisual(proyectil)
	}
	method removerProjectil(projectil){
		game.removeVisual(projectil)
		objetosMobibles.remove(projectil)
	}
}