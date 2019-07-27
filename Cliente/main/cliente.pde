import java.io.*;
import java.net.*;
import java.util.Scanner;

class Cliente {
  private BufferedReader in;
  private PrintWriter  out;

  Cliente(String host, int port){
    try{
      Socket s = new Socket(host, port);
      in = new BufferedReader(new InputStreamReader( s.getInputStream()));
      out = new PrintWriter(s.getOutputStream());
    }catch( Exception e){ System.out.println("Erro ao ligar ao servidor"); }
  }

  public String getEstado(){
    try{
      String res ="";
      while(!in.ready());
      res = in.readLine();
      System.out.println(res);
      return res;
    }catch( Exception e){ return "Nao consegui receber estado"; }
  }
  
  boolean haveMessage(){
    try{
      return in.ready();
    }catch( Exception e){ return false; }
  }

  public void sendMessage( String msg){
    System.out.println(msg);
    out.println(msg);
    out.flush();
  }

}
