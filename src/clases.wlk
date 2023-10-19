import wollok.game.*
import objects.*
class Baldosa{
    var property image
    var property position
}
class BaldosaFlecha inherits Baldosa{//Baldosas que afectan la direccion de los enemigos
    var property direcciones
    method direccion() = direcciones.anyOne()
}
//este es un ejemplo de como creariamos las baldosas esta es una valdosa que prmite moverte acia arriva o la derecha
//var baldosa = new Baldosa( direcciones  = {game.at(0,1),game.at(1,0)} )

class Enemigo{
    var property direccion
    var property image
    var property position
    var property vida
    method moverse(){
        position = game.at( position.x() + direccion.x() , position.y() + direccion.y() )
    }
    method removerse(){
    	game.removeVisual(self)
    	controlador.enemigos().remove(self)
    }
}

class Torre{
    var property image
    var property position
}

class Matias inherits Enemigo(direccion = game.at(1,0), image = "matias.png" , position = game.at(0,0) , vida = 5){

}
