import wollok.game.*
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
	var property direccion = game.at(1,0)
	var property image
	var property position
	var property vida
	method moverse(){
		position = game.at( position.x() + direccion.x() , position.y() + direccion.y() )
	}
}
class Matias inherits Enemigo(image = "matias.png" , position = game.at(0,0) , vida = 5){
	
}
object celda inherits Baldosa(image = "celda.png" , position = game.at(1,0)){
	
}
object celdadir inherits BaldosaFlecha(image = "FlechaDerecha.png" , position = game.at(2,0), direcciones = [game.at(0,1)]){
	
}
