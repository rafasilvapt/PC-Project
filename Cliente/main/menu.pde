class Menu{

	public float topScore [] = new float[3];
	public String msg = "";

	void drawMenu(){
		
    fill(0);
		int line = 0;
		text("Três melhores resultados:", width/8, height/8);

		for(float score: topScore){
			line++;
			text(line + "º " + score, width/6, height/8 + line * 40);
		}
		line+=2;
		text("1-Procurar jogo\n2-Sair da conta\n3-Remover conta",width/8, height/8 + line * 40);
	}

	void keyPressedMenu(){
      switch(key){
        case '1':
          // Procurar jogo
					estado = 2;
        	c.sendMessage("play ");
        break;
       case '2':
        	// Logout
        	c.sendMessage("logout " + login.username  + " " + login.password);
					 while(!c.haveMessage()){
                string2estado(c.getEstado());
                break;
             }
					estado = 0;
        break;
       case '3':
        	// Remover conta
        	c.sendMessage("close " + login.username + " " + login.password);
						 while(!c.haveMessage()){
                string2estado(c.getEstado());
                break;
              }
						estado = 0;
        break;
      }
	}
	void reset(){
		msg = "";
	}

	void addTopScore(float[] topScore){
		this.topScore = topScore;
	}
}	

class Login{

	public int state = 1;
	public String username = "";
	public String password = "";
 	public String spassword = "";
	public String res = "";
	public boolean isLogin;

	void reset(){
		state = 1;
		username = "";
		password = "";
		spassword = "";
		res = "";
	}

	void drawLogin(){
		switch (state) {
			case 1:
        fill(0);
				text("1-Criar conta\n2-Entrar na conta", width/4, height/2);
				break;
			case 2:
				fill(0);
				text("Utilizador:\n" + username + "_",width/4, height/2);
				break;
			case 3:
				fill(0);
				text("Palavra-passe:\n"  + spassword + "_",width/4, height/2);
        break;
			case 4:
				if(res.equals("ok")){
					estado = 1;
					c.sendMessage("getScore ");
					string2estado(c.getEstado());
					reset();
				}
				else{
					reset();
				}
		}
	}
	
	void keyPressedLogin(){
		switch (state) {
			case 1:
				if(key == '1' || key == '2'){
          isLogin = key == '2';
  				state++;
        }
			break;	
			case 2:
				if(key == ENTER){
					if(username.length() != 0 && state != 1){
						state++;
					}
				}
				else if(key == BACKSPACE  && username.length()>0 ){
					username = username.substring(0, username.length() - 1);
    		}
				else if(key != CODED){
					username = username + key;
				}
			break;
			case 3:
			if(key == ENTER){
					if(password.length() != 0){
						if(isLogin){
							c.sendMessage("login " + username + " " + password);
						}
						else {
							c.sendMessage("create " + username + " " + password);

						}
						res = c.getEstado();
						state++;
					}
				}
				else if(key == BACKSPACE  && password.length()>0 ){
					password = password.substring(0, password.length() - 1);
					spassword = spassword.substring(0, spassword.length() - 1);
    		}
				else if(key != CODED){
					password = password + key;
					spassword = spassword + "*";
				}
      break;
			case 4:
				state = 1;
				password = "";
				spassword = "";
				username = "";
		}
	}
}
