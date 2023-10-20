
import escenografiaJuego.*
import wollok.game.*
import wollok.game.*

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
    
    var property  vidaDelJugador = 3  
  	method reducirVida() {vidaDelJugador =  0.max(vidaDelJugador - 1) }
  	method revisarFinDePartida() { if (vidaDelJugador == 0) game.say(cabezal, " Fin del juego" )}
  	method instanciarEnemigo(vida_,imagen_,posicion_) = new Enemigo(vida = vida_, direccion = new Vector(x=0,y=0), image = imagen_, posicion = posicion_)
  	method agregarEnemigo(vida_,imagen_,posicion_){ 
  		const enemigo = self.instanciarEnemigo(vida_, imagen_, posicion_)
  		enemigos.add(enemigo)
  		game.addVisual(enemigo)
  	}
  	method instancearTorre(posicion_) = new Torre(objetivo = null, image = "torrePrueba.png", posicion = posicion_)
  	method agregarTorre(posicion_){
    	const torre = self.instancearTorre(posicion_)
        torres.add( torre )
        game.addVisual( torre )
    }
    method retirarEnemigo(enemigo){ 
    	game.removeVisual(enemigo) 
    	enemigos.remove(enemigo)
    }
    
}
