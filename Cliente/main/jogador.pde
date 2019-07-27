class Jogador{
    PVector posicao;
    int cor_R = 0, cor_G = 0, cor_B = 0;
    int cor_stroke_R = 0, cor_stroke_G  = 0, cor_stroke_B = 0; //preto
    float massa ;  //área do círculo proporcional à massa do jogador
    int nPlayer;
    
    Jogador(){
      posicao = new PVector(0.0,0.0); //definir 
       massa = 1;
    }
    

    public void desenha(){
      pushMatrix();
      translate(posicao.x, posicao.y);
      fill(cor_R, cor_G, cor_B); // preto
      stroke(cor_stroke_R,cor_stroke_G,cor_stroke_B); //azul se sou eu , vermelho se é o outro
      ellipse(0, 0,massa,massa);
      popMatrix();
    }
    
    public void setPosicao(float x, float y) {
		posicao.x = x;
		posicao.y = y;
    }
    public void setMassa(float m){
      massa = m;
    }
    public void setCor(int n){
      if(n == 1){
        cor_stroke_B = 255;
        cor_stroke_R = 0;
      }
      else{
        cor_stroke_R = 255;
        cor_stroke_B = 0;
      }
    }
}

class Bola{
    PVector posicao;
    int cor_R , cor_G , cor_B; //verde se for comestivel, vermelho para objetos venenosos
    int tipo; //verde se for comestivel, vermelho para objetos venenosos
    float massa ;  //tem um tam fixo definido na sua criação, podendo existir objectos de vários tam
    
    public Bola(int t, float x, float y, float m){
      posicao = new PVector(x,y); //definir 
      tipo = t;
      massa = m;
    }
    
    void desenha(){
		pushMatrix();
		translate(posicao.x, posicao.y);
		if( tipo==1 ) fill( 0, 255, 0);
		else fill(255,0,0);
    noStroke();
		ellipse(0,0, massa, massa); 
		popMatrix();
  	} 
    
    public void setPosicao(float x, float y) {
      posicao.x = x;
      posicao.y = y;
    }
    public void setMassa(float m){
      massa = m;
    }
    
    public void setTipo(int t){
      tipo = t;
    }
    
}
