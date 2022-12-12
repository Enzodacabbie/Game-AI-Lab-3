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
   Cell[] cells;
   int start;
   
   Map()
   {
      walls = new ArrayList<Wall>();
   }
  
   
   
   void generate(int which)
   {
      walls.clear();
      int widthNum = width/GRID_SIZE;
      int heightNum = height/GRID_SIZE;
      int cellNum = widthNum * heightNum;
      cells = new Cell[cellNum];
      
      //Creates walls at intervals of GRID_SIZE to make the grid
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
      
      //Initialize cells
      for(int i = 0; i < cellNum; i++)
      {
        cells[i] = new Cell();
      }
      
      //Goes through walls and determines which are the sides of each cell
      int num = 0;
      for(int j = 0; j <= width - GRID_SIZE; j += 40)
        {
          for(int k = 0; k <= height - GRID_SIZE; k += 40)
          {
           for(Wall w : walls)
           {
             if((w.start.x == j && w.start.y == k) || (w.end.x == j+GRID_SIZE && w.end.y == k+GRID_SIZE))
             {
               cells[num].sides.add(w);
             }
           }
           num++;
          }
        }
        
        //Calculates the center of each cell using the four sides
        for(Cell c : cells)
        {
         PVector sum = new PVector(0, 0);
         for(Wall s : c.sides)
         {
           sum.add(s.center());
         }
         sum.div(4);
         
         c.cellCenter = sum;
        }
        
        //Determines the neighbors of each cell by comparing common walls
        for(int i = 0; i < cellNum; i++)
        {
         for(int j = i; j < cellNum; j++)
         {
          if(i != j)
          {
            for(Wall iWall : cells[i].sides)
            {
             for(Wall jWall : cells[j].sides)
             {
              if((iWall.start == jWall.start ) && (iWall.end == jWall.end))
              {
               if(!cells[i].neighbors.contains(cells[j]))
               {
                cells[i].neighbors.add(cells[j]); 
               }
               if(!cells[j].neighbors.contains(cells[i]))
               {
                cells[j].neighbors.add(cells[i]); 
               }
              }
             }
            }
          }
         }
        }
        
        //Determine the starting point
        start = (int)random(widthNum * heightNum);
      
      //Print sides of a cell for testing
      for(int i = 0; i < cells[0].sides.size(); i++){
        System.out.println(cells[0].sides.get(i));
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
      
      //Draws center of each cell
      for(Cell c : cells)
      {
        stroke(#ffea00);
        circle(c.cellCenter.x, c.cellCenter.y, 5);
      }
      
      //Draws lines connecting neighbors
      strokeWeight(1.5);
      for(Cell c : cells)
      {
        for(Cell n : c.neighbors)
        {
         line(c.cellCenter.x, c.cellCenter.y, n.cellCenter.x, n.cellCenter.y); 
        }
      }
      
      //Shows selected starting cell
      stroke(#eb4034);
      circle(cells[start].cellCenter.x, cells[start].cellCenter.y, 10);
   }
}

class Cell
{
  ArrayList<Wall> sides = new ArrayList<Wall>();
  PVector cellCenter;
  ArrayList<Cell> neighbors = new ArrayList<Cell>();
}
