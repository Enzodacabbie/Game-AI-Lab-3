class Wall
{
   PVector start;
   PVector end;
   PVector normal;
   PVector direction;
   float len;
   boolean isEdge;
   
   Wall(PVector start, PVector end)
   {
      this.start = start;
      this.end = end;
      direction = PVector.sub(this.end, this.start);
      len = direction.mag();
      direction.normalize();
      normal = new PVector(-direction.y, direction.x);
      isEdge = false;
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
            Wall addWall = new Wall(new PVector(i, j), new PVector(i+GRID_SIZE, j));
            addWall.isEdge = isWallEdge(addWall);
            walls.add(addWall);
          }
          if(j != height)
          {
            Wall addWall = new Wall(new PVector(i, j), new PVector(i, j+GRID_SIZE));
            addWall.isEdge = isWallEdge(addWall);
            walls.add(addWall);
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
      for(int j = 0; j <= width - GRID_SIZE; j += GRID_SIZE)
        {
          for(int k = 0; k <= height - GRID_SIZE; k += GRID_SIZE)
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
        
        /**
        int currentWidth = 0;
        int currentHeight = 1;
        
        for(int j = 0; j < cells.length; j++)
        {
          cells[j].sides.add(walls.get(currentWidth));
          cells[j].sides.add(walls.get(currentHeight));
          cells[j].sides.add(walls.get(currentWidth + 2));
          cells[j].sides.add(walls.get(currentHeight + GRID_SIZE + 2));
          
          currentWidth = currentWidth + 1;
          currentHeight = currentHeight +1;
        }
        */
        
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
        
        //for(int i = 0; i < cellNum; i++)
        //{
        // for(int j = i; j < cellNum; j++)
        // {
        //  if(i != j)
        //  {
        //    for(Wall iWall : cells[i].sides)
        //    {
        //     for(Wall jWall : cells[j].sides)
        //     {
        //      if((iWall.start == jWall.start ) && (iWall.end == jWall.end))
        //      {
        //       if(!cells[i].neighbors.contains(cells[j]))
        //       {
        //        cells[i].neighbors.add(cells[j]); 
        //       }
        //       if(!cells[j].neighbors.contains(cells[i]))
        //       {
        //        cells[j].neighbors.add(cells[i]); 
        //       }
        //      }
        //     }
        //    }
        //  }
        // }
        //}
        
        
        //Determine the starting point
        start = (int)random(widthNum * heightNum);
        
        prims(walls, cells, cells[start]);
      
      //Print sides of a cell for testing
      for(int i = 0; i < cells[0].sides.size(); i++){
        System.out.println(cells[0].sides.get(i));
      }
   }
   
   //used to check if newly created wall is on the edge of the screen
   boolean isWallEdge(Wall w)
   {
     if((w.start.x == 800 && w.end.x == 800) || (w.start.x == 0 && w.end.x == 0))
     {
       return true;
     }
     
     if((w.start.y == 600 && w.end.y == 600) || (w.start.y == 0 && w.end.y == 0))
     {
       return true;
     }
     else
       return false;
   }
   
   //main prims implementation
   void prims(ArrayList<Wall> w, Cell[] c, Cell start)
   {
     ArrayList<Wall> frontier = new ArrayList<Wall>();
     ArrayList<Cell> visitedCells = new ArrayList<Cell>();
     
     visitedCells.add(start);
     frontier.addAll(start.sides);
     System.out.println(frontier.size());
     
     while(visitedCells.size() < c.length)
     {
       //select a random wall from the frontier
       int index = (int)(Math.random() * frontier.size());
       Wall selected = frontier.get(index);
       
       //if the wall is on the edge of the screen, it cannot be used
       if(selected.isEdge == true)
       {
         continue;
       }
       
       Cell selectedCell = new Cell();
       for(int i = 0; i < visitedCells.size(); i++)
       {
         if(visitedCells.get(i).sides.contains(selected))
         {
           selectedCell = visitedCells.get(i);
           break;
         }
       }
       
       for(int i = 0; i < c.length; i++)
       {
         if(c[i].sides.contains(selected) && !visitedCells.contains(c[i]))
         {
           w.remove(selected);
           Cell neighbor = c[i];
           c[i].visited = true;
           selectedCell.neighbors.add(neighbor);
           visitedCells.add(neighbor);
           frontier.addAll(neighbor.sides);
           break;
         }
       }

       frontier.remove(index);
       System.out.println(frontier.size());
     }
     System.out.println(c.length);
     walls = w;
     
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
        stroke(#c53dff);
        circle(c.cellCenter.x, c.cellCenter.y, 3);
      }
      
      //Draws lines connecting neighbors

      strokeWeight(0.5);
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
  
  boolean visited;
  
  Cell()
  {
    visited = false;
  }
}
