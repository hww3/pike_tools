#!/usr/local/bin/pike

int in_module;
string curr_mod;
ADT.Stack s = ADT.Stack();

int main(int argc, array argv)
{
  if(argc<2) 
  {
    do_help(argv);
    exit(1);
  }

  object regex = Regexp.SimpleRegexp("^PIKE(FUN|CLASS)");

  werror("Parsing file %s\n", argv[1]);
  foreach(Stdio.FILE(argv[1], "r")->line_iterator(); int lineno; string line)
  {
    if(!regex->match(line)) {write(line + "\n"); continue;}
    line = String.trim_all_whites(line);
    if(has_prefix(line, "PIKECLASS"))
    {
      string oldmod;
      string newmod;

      if(sizeof(s))
        oldmod = s->pop();
      newmod = ((line/" ")- ({""}))[1];
      s->push(newmod);
      curr_mod = newmod;
      if(oldmod) write("/*!  @endclass\n*/\n\n");

      write("/*! @class %s\n*/\n\n", newmod);
      write(line + "\n");
    }
    if(has_prefix(line, "PIKEFUN"))
    {
      string decl = line[8..];
      string returntype;
      string params;
      array p = ({});

      write("/*  %s.%s */\n", curr_mod, decl);
      write("/*! @decl %s\n *!\n *!  \n", decl);

      sscanf(decl, "%s %*s(%s)", returntype, params);

//      werror("Returntype: %s\n", returntype);

      if(params && sizeof(params))
        foreach(params/",";; string pi)
        {
          write(" *! @param %s\n *!  \n* !\n", ((String.trim_whites(pi)/" ")[-1]));
        }
        if(returntype!="void")
          write(" *! @returns\n *!  \n");
      
        write(" *!\n */\n");
        write(line + "\n");
    }
    in_module++;
  }

  if(sizeof(s)) write("/*!  @endclass\n */\n");

  return 0;
}

void do_help(array argv)
{
  werror("Usage: %s docfile\n", argv[0]);
}
