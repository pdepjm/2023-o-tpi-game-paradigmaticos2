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
}

const vectorNulo = new Vector( x=0, y=0)
const arriba = new Vector(x=0,y=1)
const abajo = new Vector(x=0,y=-1)
const derecha = new Vector(x=1,y=0)
const izquierda = new Vector(x=-1,y=0)


class ObjetoDeJuego{//clase creada para ahorrar repetir 
	var property image
	var posicion 
	method position() = posicion
	method impactar(bala) {}
	method pisar(objeto){}
	method alinear(direccion_){}
}

class BaldosaFlecha inherits ObjetoDeJuego{//Baldosas que afectan la direccion de los enemigos
    var property direccion
    override method pisar(objeto_){
    	objeto_.direccion(direccion)
    	objeto_.mover()
    }
}//nota baldosas no deberia eredar dado que podemos hacer que se asigne una imagen en base a su lista de direcciones/

class BaldosaFinal inherits ObjetoDeJuego{
	override method pisar(objeto_){
		objeto_.morir()
		interfazUsuario.reducirVida()
	}
}

class BaldosaInterseccion inherits ObjetoDeJuego{
	override method pisar(objeto_){
		objeto_.mover()
	}
}
class BaldosaBoost inherits BaldosaFlecha{
	override method pisar(objeto_){
		objeto_.ascender()
		super(objeto_)
	}
}

class BaldosaCuracion inherits BaldosaFlecha{
	override method pisar(objeto_){
		objeto_.curar()
	}
}



class Enemigo inherits ObjetoDeJuego{
    var vida 
    var direccion
    var tipo = "orco"
    const curacion = 1
    
    method ascender(){
    	tipo = "Matias"
    	vida = 5
    }
    method direccion(direccion_){
    	direccion = direccion_
    	self.image(tipo+direccion.vectorAString()+".png")
    }
    method morir(){
    	interfazUsuario.dineroDelJugador(10)
    	controlador.retirarEnemigo(self)
    }
    method moverse() {
    	controlador.camino().find{obj_ => obj_.position().iguales(posicion)}.pisar(self)
    	//game.colliders(self).forEach{colider => colider.pisar(self)}
    }
    method mover(){
    	posicion = posicion.sumar(direccion)
    }
    override method impactar(bala) {
    	vida = vida - 1
    	if(vida == 0) self.morir()
    	bala.destruir()
    }
    method curar(){
    	vida += curacion
    }
}

class Torre inherits ObjetoDeJuego{
    
    var contador = 1//para asegurar que no disare en el instante que es creada
    var direccion 
    
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
    override method alinear(direccion_){
    	direccion = direccion_
    	image = "torre"+direccion.vectorAString()+".png"
    }
   

}

class Proyectil inherits ObjetoDeJuego{
	
	var direccion
	var pasosDados = 6
	
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

const imagenInicio = new ObjetoDeJuego(posicion = instanciador.vector(0,0) , image = "imagenInicio.jpg" )