import wollok.game.*
import administrativo.*


class Vector inherits Position {//los metodos agregados existen para mover objetos y determinar posiciones relativas
//de objetos esto servira para poder hacer que las torretas "roten" a futuro
	
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
	method rotar90grados() = new Vector(x= -y, y= x)
	method iguales(punto) = punto.x() == x and punto.y() == y
	method vectorAString(){
		if ( x == 1 ){
			return "Derecha"
		}else if(x == -1){
			return "Izquierda"
		}else if(y == 1){
			return  "Arriba"
		}else if(y == -1){
			return "Abajo"
		}
		return ""
	}
	method productoPunto(vector) = vector.x()*self.x() + vector.y()*self.y()
	method cuadradoDistancia() = self.productoPunto(self)
	method productoCruz(vector) = vector.x()*self.y() - self.x()*vector.y()
	method esSubVectorDe(vector){
		return self.productoPunto(vector) > 0 and self.cuadradoDistancia()  <= vector.cuadradoDistancia() and self.productoCruz(vector) == 0
	}
}

const vectorNulo = new Vector( x=0, y=0)

class ObjetoDeJuego{//clase creada para ahorrar repetir 
	var property image
	var posicion 
	method position() = posicion
	method impactar(bala) {}
}

class BaldosaFlecha inherits ObjetoDeJuego{//Baldosas que afectan la direccion de los enemigos
    var property direcciones
    method direccion() = direcciones.anyOne()
}//nota baldosas no deberia eredar dado que podemos hacer que se asigne una imagen en base a su lista de direcciones

class Enemigo inherits ObjetoDeJuego{
    var vida
    var pasosDados = 1 //decimos que si esta en una casilla ya dio un paso 
    var camino
    method pasosDados() = pasosDados
    method solicitarDireccion() = camino.darDireccion(pasosDados-1)//tiene que ser -1 por que accedemos a una lista con esta funcion
    method solicitarCamino() {camino = controlador.asignarCamino(posicion)}
    method morir(){
    	controlador.retirarEnemigo(self)
    }
    method moverse() {
    	const direccion = self.solicitarDireccion()
    	if (direccion.iguales(vectorNulo)) {
    		controlador.reducirVida()
    		self.morir()
    	}
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
    
    override method impactar(bala) {
    	vida = vida - 1
    	if(vida == 0) self.morir()
    	bala.destruir()
    }
}

class Torre inherits ObjetoDeJuego{//de momento la dejo asi mañana a la noche regreso por mas
    
    var objetivo
    //var proyectil
    
    var contador = 1//para asegurar que no disare en el instante que es creada
    var direccion 
    
    method direccion( direccion_) {
    	direccion = direccion_
    }
    
    override method image() = "torre"+direccion.vectorAString()+".png" 
    
    method cargarBala(){
    	controlador.agregarPoryectil(posicion.sumar(direccion), direccion,"ball.png")
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
    method esMiPosicion(posicion_) = posicion.iguales(posicion_)
}

class Proyectil inherits ObjetoDeJuego{
	
	var direccion
	var pasosDados = 4
	
	method mover(){
		posicion = posicion.sumar(direccion)
	}
	method destruir(){controlador.removerProjectil(self)}
	method moverse(){
		self.mover()
		pasosDados -= 1
		if ( pasosDados == 0 ){
			self.destruir()
		}
	}
}

//previamente conocido como Matias
class Villano inherits Enemigo(image = "matias.png" , posicion = new Vector(x = 0, y = 0) , vida = 5){

}
