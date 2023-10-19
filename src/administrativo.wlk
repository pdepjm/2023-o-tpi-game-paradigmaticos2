
import escenografiaJuego.*
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
    method agregarTorre(listaTorres){
        listaTorres.add(new Torre( image = "torrePrueba.png",position = self.position()))
        game.addVisual(listaTorres.last())
    }
}

//objeto que contiene las dos listas que usaremos en el juego 
//ir a explicacion N°2 explicaciones.txt
object controlador {
    const property torretas = []
    const property enemigos = []
    const property baldosas = [ new Baldosa( position = game.at(0,0), image = "celda.png"), new BaldosaFlecha( position = game.at(1,0),
    	 image = "celda.png", direcciones= [game.at(0,1)] ) , new Baldosa( position = game.at(1,1), image = "celda.png"),
    	  new Baldosa( position = game.at(1,2), image = "celda.png")
    ] 
    var property  vida = 3  
  	method reducirVida() {vida =  0.max(vida - 1) }
  	method revisarFinDePartida() { if (vida == 0) game.say(cabezal, " Fin del juego" )}
}
