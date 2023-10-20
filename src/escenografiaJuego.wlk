import wollok.game.*
import administrativo.*


class Vector{//los metodos agregados existen para mover objetos y determinar posiciones relativas
//de objetos esto servira para poder hacer que las torretas "roten" a futuro
	var property x
	var property y
	//MATEMATICAS :D!!!!!
	method sumar(vector) = new Vector(x = vector.x() + self.x() , y = vector.y() + self.y()) 
	method vectorHaciaPunto(punto) = new Vector( x = punto.x() + self.x(), y = punto.y() + self.y())
	method vectorEstaInclinado(vector) = self.vectorHaciaPunto(vector).x().abs() < self.vectorHaciaPunto(vector).y().abs()
	method puntoEstaArriva(vector) = self.vectorEstaInclinado(vector) and self.vectorHaciaPunto(vector).y() > 0
	method puntoEstaAbajo(vector) = self.vectorEstaInclinado(vector) and self.vectorHaciaPunto(vector).y() < 0
	method puntoEstaDerecha(vector) = self.vectorEstaInclinado(vector).negate() and self.vectorHaciaPunto(vector).x() > 0
	method puntoEstaIzquierda(vector) = self.vectorEstaInclinado(vector).negate() and self.vectorHaciaPunto(vector).x() < 0
	method distanciaManhattan(punto) = self.vectorHaciaPunto(punto).x().abs() + self.vectorHaciaPunto(punto).y().abs()
	method vectorAPosition() = game.at( x , y)
	method vector(x_,y_) { x = x_  y = y_}
}
class ObjetoDeJuego{//clase creada para ahorrar repetir 
	var property image
	var posicion 
	method position() = posicion.vectorAPosition()
}
class BaldosaFlecha inherits ObjetoDeJuego{//Baldosas que afectan la direccion de los enemigos
    var property direcciones
    method direccion() = direcciones.anyOne()
}

class Enemigo inherits ObjetoDeJuego{
    var vida
    var direccion
    method moverse() { posicion = posicion.sumar(direccion)}
    method reducirVida(){ vida = vida - 1}
}

class Torre inherits ObjetoDeJuego{//de momento la dejo asi mañana a la noche regreso por mas
    var objetivo
    method objetivo(nuevoOvjetivo){ objetivo = nuevoOvjetivo }
}

//previamente conocido como Matias
class Villano inherits Enemigo(direccion = new Vector(x=1,y=0), image = "matias.png" , posicion = new Vector(x = 0, y = 0) , vida = 5){

}

