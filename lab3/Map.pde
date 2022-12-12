class Wall
{
   PVector start;
   PVector end;
   PVector normal;
   PVector direction;
   float len;
   
   Wall(PVector start, PVector end)
   {
      this.start = start;
      this.end = end;
      direction = PVector.sub(this.end, this.start);
      len = direction.mag();
      direction.normalize();
      normal = new PVector(-direction.y, direction.x);
   }
   
   // Return the mid-point of this wall
   PVector center()
   {
      return PVector.mult(PVector.add(start, end), 0.5);
   }
   
   void draw()
   {
       strokeWeight(3);
       line(start.x, start.y, end.x, end.y);
       if (SHOW_WALL_DIRECTION)
       {
          PVector marker = PVector.add(PVector.mult(start, 0.2), PVector.mult(end, 0.8));
          circle(marker.x, marker.y, 5);
       }
   }
}


class Map
{
   ArrayList<Wall> walls;
   
   Map()
   {
      walls = new ArrayList<Wall>();
      
   }
  
   
   
   void generate(int which)
   {
      walls.clear();
      
      for(int i = 0; i <= width; i += GRID_SIZE)
      {
        for(int j = 0; j <= height; j += GRID_SIZE)
        {
          if(i != width)
          {
            walls.add(new Wall(new PVector(i, j), new PVector(i+GRID_SIZE, j)));
          }
          if(j != height)
          {
            walls.add(new Wall(new PVector(i, j), new PVector(i, j+GRID_SIZE)));
          }
        }
      }
   }
   
   void update(float dt)
   {
      draw();
   }
   
   void draw()
   {
      stroke(255);
      strokeWeight(3);
      for (Wall w : walls)
      {
         w.draw();
      }
   }
}
