import wollok.game.*
import administrativo.*


class Vector{//los metodos agregados existen para mover objetos y determinar posiciones relativas
//de objetos esto servira para poder hacer que las torretas "roten" a futuro
	var x
	var y
	
	method x() = x
	method y() = y
	
	method up(){ y =+ 1 }
	method down(){ y =- 1 }
	method right(){ x =+ 1 }
	method left(){ x =- 1 }
	
	method devolverVector() = new Vector(x = x, y = y)
	//MATEMATICAS :D!!!!!
	method sumar(vector) = new Vector(x = vector.x() + x , y = vector.y() + y) 
	method vectorHaciaPunto(punto) = new Vector( x = punto.x() - x, y = punto.y() - y)
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
    	else 
    	{
    		posicion = posicion.sumar(direccion)
    		pasosDados = pasosDados + 1
    		if (pasosDados > camino.size()) 
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
    //var proyectil
    
    var contador = 1//para asegurar que no disare en el instante que es creada
    var disparaArriba
    var disparaAbajo
    var disparaIzquierda
    var disparaDerecha
    
    method cargarBala(){
    	var direccion 
    	if(disparaArriba){
    		direccion = new Vector(x=0,y=1)
    		controlador.agregarPoryectil(posicion, direccion)
    	}
    	else if(disparaAbajo){
    		direccion = new Vector(x=0,y=-1)
    		controlador.agregarPoryectil(posicion, direccion)
    	}
    	else if(disparaIzquierda){
    		direccion = new Vector(x=1,y=0)
    		controlador.agregarPoryectil(posicion, direccion)
    	}
    	else if(disparaDerecha){
    		direccion = new Vector(x=-1,y=0)
    		controlador.agregarPoryectil(posicion, direccion)
    	}
    	
    }
    method disparar(){
    	if ( contador <= 0 ){
    		self.cargarBala()
    		contador = 2
    	}else{
    		contador -= 1
    	}
    }
    method objetivo(nuevoOvjetivo){ objetivo = nuevoOvjetivo }
}

class Proyectil inherits ObjetoDeJuego{
	
	var direccion
	var pasosDados = 12
	
	method mover(){
		posicion = posicion.sumar(direccion)
	}
	method destruir(){controlador.removerProjectil(self)}
	method moverse(){
		self.mover()
		pasosDados -= 1
		if ( pasosDados == 0 ) {self.destruir()}
	}
}

//previamente conocido como Matias
class Villano inherits Enemigo(image = "matias.png" , posicion = new Vector(x = 0, y = 0) , vida = 5){

}