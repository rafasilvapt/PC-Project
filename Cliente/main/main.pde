Menu menu;
Login login;
Jogador j1, j2;
ArrayList <Bola> bolas;
Cliente c;
int estado;
int nPlayer;
boolean [] keys;

void setup(){
    bolas = new ArrayList <Bola>();
    estado = 0;
    size(700,700);
    textSize(26);
    menu = new Menu();
    login = new Login();
	  j1 = new Jogador();
	  j2 = new Jogador();
    keys = new boolean[4];
    c = new Cliente("192.168.100.187", 12345);
}

void draw(){
    background(255);
    switch(estado){
        case 0:
            login.drawLogin();
        break;
        case 1:
            menu.drawMenu();
        break;
        case 2:
            text("À procura de outro jogador...", width/4, height/2);
            if(c.haveMessage())
              string2estado(c.getEstado());
        break;
        case 3:
            background(255);
            desenhaJogo();
        break;
    }
}

void keyPressed(){
  if(estado == 0) login.keyPressedLogin();
  if(estado == 1) menu.keyPressedMenu();
  if(estado == 3){
        if (key == 'w') {
            if(!keys[2]){
              keys[0] = true;
            }
    }else if (key == 'a') {
            if(!keys[3]){
              keys[1] = true;
            }
    }else if (key == 's') {
            if(!keys[0]){
              keys[2] = true;
            }
    } else if (key == 'd') {
            if(!keys[1]){
              keys[3] = true;
            }
    }
    key2Message();
  }
}

void keyReleased(){
    if(estado == 3){
        if (key == 'w') {
          keys[0] = false;
    }else if (key == 'a') {
          keys[1] = false;
    }else if (key == 's') {
          keys[2] = false;
    } else if (key == 'd') {
          keys[3] = false;
    }
  }
}

void resetKey(){
  for(int i = 0; i<4; i++){
    keys[i] = false;
  }
}

void key2Message(){
  if(keys[0] && keys[1]){
    c.sendMessage("esqfrente ");
  }else if(keys[1] && keys[2]){
    c.sendMessage("esqtras ");
  }else if(keys[2] && keys[3]){
    c.sendMessage("dirtras ");
  }else if(keys[0] && keys[3]){
    c.sendMessage("dirfrente ");
  }else if(keys[0]){
    c.sendMessage("frente ");
  }else if(keys[1]){
    c.sendMessage("esquerda ");
  }else if(keys[2]){
    c.sendMessage("tras ");
  }else if(keys[3]){
    c.sendMessage("direita ");
  } 
}

void desenhaJogo(){

    String estadoS;
    if(c.haveMessage()){
    estadoS = c.getEstado();
    string2estado(estadoS);
    }
    j1.desenha();
    j2.desenha();

    for(Bola b : bolas) b.desenha();
}


void string2estado(String e){

    e = e.replace('.',',');
    Scanner scanner = new Scanner(e);

    float x, y, tam;
    int t;

    if(estado == 2){
      if(scanner.hasNext("startGame")){
          scanner.next();
          nPlayer = scanner.nextInt();
          if(nPlayer == 1){
              j1.setCor(1);
              j2.setCor(2);
          }
          else{
              j2.setCor(1);
              j1.setCor(2);
          }
          resetKey();
          estado = 3;
          System.out.println(estado);
          scanner.close();
          return;
      }
      scanner.close();
      return;
    }

    if(scanner.hasNext("endGame")){
        scanner.next();
        estado = 1;
        c.sendMessage("getScore ");
        string2estado(c.getEstado());
        scanner.close();
        return;
    }

    if(estado == 1){
        menu.topScore = new float[3];
        for(int i = 0; i < 3; i++){
          if(scanner.hasNextFloat()){
            menu.topScore[i] = scanner.nextFloat();
          }
        }
        scanner.close();
        return;
    }

    scanner.next();
    x = scanner.nextFloat();
    y = scanner.nextFloat();
    
    j1.setPosicao(x,y);

    tam = scanner.nextFloat();

    j1.setMassa(tam);

    scanner.next();

    scanner.next();
    x = scanner.nextFloat();
    y = scanner.nextFloat();
    
    j2.setPosicao(x,y);

    tam = scanner.nextFloat();

    j2.setMassa(tam);

    scanner.next();

    bolas.clear();

    while(scanner.hasNext()){
        x = scanner.nextFloat();
        y = scanner.nextFloat();
        tam = scanner.nextFloat();
        t = scanner.nextInt();
        bolas.add(new Bola(t,x,y,tam));
    }
    scanner.close();
}
