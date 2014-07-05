package me.army8735.xcution
{
  import flash.display.Sprite;
  import me.army8735.xcution.http.HttpServer;
  
  public class Xcution extends Sprite
  {
    private var httpServer:HttpServer;
    
    public function Xcution()
    {
      httpServer = new HttpServer();
    }
  }
}