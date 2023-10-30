
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
    var property image = "celda.png"
    var property position = game.center() 

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
    method colocarTorre(){controlador.agregarTorre(new Vector(x=position.x(),y=position.y()))}
    
    //method hayUnaTorrePresente() = //devolvera true si en la lista de torres existe una que tenga la misma posicion que el cabezal 
}

//El controlador se encarga de todo el tema de poner y sacar objetos los demas objetos solo le pediran que lo haga por ellos 
object controlador {
	//no hay razon para que otros objetos puedan tocar las listas a si que las dejamos sin property
    const torres = []
    const enemigos = []
    const listaDeCaminos = []
    var vidaDelJugador = 3
      
//  var property debeDispararDerecha = initialValue
	
	method abranFuego() { torres.forEach{torre => torre.disparar()} }
	method reducirVida() {vidaDelJugador =  0.max(vidaDelJugador - 1) }
  	method revisarFinDePartida() { if (vidaDelJugador == 0) game.say(cabezal, " Fin del juego" )}
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
    }
    method moverEnemigos(){enemigos.forEach({enemigo => enemigo.moverse()})}
  	method instancearTorre(posicion_) = new Torre(objetivo = null, proyectil = new Proyectil(image = "ball.png", posicion = posicion_), image = "torrePrueba.png", posicion = posicion_, disparaArriba = true, disparaAbajo = false, disparaIzquierda = true, disparaDerecha = false)
  	method agregarTorre(posicion_){
    	const torre = self.instancearTorre(posicion_)
        torres.add( torre )
        game.addVisual( torre )
    }
    method agregarCamino(direccionesSiguientesCaminos_,direccionPropia_,posicion_,largo_){
    	const camino_ = new Camino(direccionescaminosAdyacentes = direccionesSiguientesCaminos_, direccionPropia = direccionPropia_, posicion = posicion_)
    	camino_.construirCamino(largo_)
    	listaDeCaminos.add(camino_)
    }
    method vector(x_,y_) = new Vector(x=x_,y=y_)
    

    method debeDispararArriba(vector) = return enemigos.any{enemigo => enemigo.position().x() == vector.x() and enemigo.position().y() > vector.y()}
  	method debeDispararAbajo(vector) = return enemigos.any{enemigo => enemigo.position().x() == vector.x() and enemigo.position().y() < vector.y()}
	method debeDispararIzquierda(vector) = return enemigos.any{enemigo => enemigo.position().x() == vector.y() and enemigo.position().y() > vector.y()}
	method debeDispararDerecha(vector) = return enemigos.fany{enemigo => enemigo.position().x() == vector.y() and enemigo.position().y() < vector.y()}
}




