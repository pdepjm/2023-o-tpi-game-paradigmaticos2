import wollok.game.*
import administrativo.*


class Vector{//los metodos agregados existen para mover objetos y determinar posiciones relativas
//de objetos esto servira para poder hacer que las torretas "roten" a futuro
	var property x
	var property y
	
	//MATEMATICAS :D!!!!!
	method sumar(vector) = new Vector(x = vector.x() + self.x() , y = vector.y() + self.y()) 
	method vectorHaciaPunto(punto) = new Vector( x = punto.x() - self.x(), y = punto.y() - self.y())
	method multiplicar(factor) = new Vector( x = x * factor , y = y * factor)
	method sumarVectorEscalado(vector, factor) = self.sumar(vector.multiplicar(factor))
	method vectorEstaInclinado(vector) = self.vectorHaciaPunto(vector).x().abs() < self.vectorHaciaPunto(vector).y().abs()
	method puntoEstaArriva(vector) = self.vectorEstaInclinado(vector) and self.vectorHaciaPunto(vector).y() > 0
	method puntoEstaAbajo(vector) = self.vectorEstaInclinado(vector) and self.vectorHaciaPunto(vector).y() < 0
	method puntoEstaDerecha(vector) = self.vectorEstaInclinado(vector).negate() and self.vectorHaciaPunto(vector).x() > 0
	method puntoEstaIzquierda(vector) = self.vectorEstaInclinado(vector).negate() and self.vectorHaciaPunto(vector).x() < 0
	method distanciaManhattan(punto) = self.vectorHaciaPunto(punto).x().abs() + self.vectorHaciaPunto(punto).y().abs()
	method vectorAPosition() = game.at( x , y)
	method vector(x_,y_) { x = x_  y = y_}
	method iguales(punto) = punto.x() == x and punto.y() == y
}

const vectorNulo = new Vector( x=0, y=0)

class ObjetoDeJuego{//clase creada para ahorrar repetir 
	var property image
	var posicion //es un vector no un game.at()
	method position() = posicion.vectorAPosition()
}

class BaldosaFlecha inherits ObjetoDeJuego{//Baldosas que afectan la direccion de los enemigos
    var property direcciones
    method direccion() = direcciones.anyOne()
}//nota baldosas no deberia eredar dado que podemos hacer que se asigne una imagen en base a su lista de direcciones

class Camino{
	const direccionescaminosAdyacentes
	const direccionPropia
	const posicion
	const property largoDelCamino
	const property baldosas = []
	
	method esMiPosicion(posicion_) = posicion.iguales(posicion_)
	method darDireccion(baldosa_) = baldosas.get(baldosa_).direccion()
	method crearBaldosa(posicion_,direcciones_)=new BaldosaFlecha(direcciones = direcciones_, image = "celda.png", posicion = posicion_)
	method construirCamino(){
		(largoDelCamino-1).times({
			i => baldosas.add(self.crearBaldosa(posicion.sumarVectorEscalado(direccionPropia,i-1),[direccionPropia]))
		})
		baldosas.add(self.crearBaldosa(posicion.sumarVectorEscalado(direccionPropia,largoDelCamino-1),direccionescaminosAdyacentes))
		baldosas.forEach({baldosa => game.addVisual(baldosa)})
	}
}

class Enemigo inherits ObjetoDeJuego{
    var vida
    var pasosDados = 1 //decimos que si esta en una casilla ya dio un paso 
    var camino
    method solicitarDireccion() = camino.darDireccion(pasosDados-1)//tiene que ser -1 por que accedemos a una lista con esta funcion
    method solicitarCamino() {camino = controlador.asignarCamino(posicion)}
    method morir(){
    	controlador.reducirVida()
    	controlador.retirarEnemigo(self)
    }
    method moverse() {
    	const direccion = self.solicitarDireccion()
    	if (direccion.iguales(vectorNulo)) {self.morir()}
    	else {
    		posicion = posicion.sumar(direccion)
    		pasosDados = pasosDados + 1
    		if (pasosDados > camino.largoDelCamino()) 
    		{
    			self.solicitarCamino() 
    			pasosDados = 1
    		}
    		
    	}
    }
    method reducirVida(){ vida = vida - 1}
}

class Torre inherits ObjetoDeJuego{//de momento la dejo asi mañana a la noche regreso por mas
    var objetivo
    method objetivo(nuevoOvjetivo){ objetivo = nuevoOvjetivo }
}

//previamente conocido como Matias
class Villano inherits Enemigo(image = "matias.png" , posicion = new Vector(x = 0, y = 0) , vida = 5){

}

