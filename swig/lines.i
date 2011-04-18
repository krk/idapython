// FIXME: These should be fixed
%ignore requires_color_esc;
%ignore tag_on;
%ignore tag_off;
%ignore tag_addchr;
%ignore tag_addstr;
%ignore get_user_defined_prefix;
// Ignore va_list versions
%ignore printf_line_v;
%ignore gen_colored_cmt_line_v;
%ignore gen_cmt_line_v;
%ignore add_long_cmt_v;
%ignore describex;
// Kernel-only and unexported symbols
%ignore init_sourcefiles;
%ignore save_sourcefiles;
%ignore term_sourcefiles;
%ignore move_sourcefiles;
%ignore gen_xref_lines;
%ignore ml_getcmt_t;
%ignore ml_getnam_t;
%ignore ml_genxrf_t;
%ignore ml_saver_t;
%ignore setup_makeline;
%ignore MAKELINE_NONE;
%ignore MAKELINE_BINPREF;
%ignore MAKELINE_VOID;
%ignore MAKELINE_STACK;
%ignore save_line_in_array;
%ignore init_lines_array;
%ignore finish_makeline;
%ignore gen_labeled_line;
%ignore gen_lname_line;
%ignore makeline_producer_t;
%ignore set_makeline_producer;
%ignore closing_comment;
%ignore close_comment;
%ignore copy_extra_lines;
%ignore ExtraLines;
%ignore ExtraKill;
%ignore ExtraFree;
%ignore Dumper;
%ignore init_lines;
%ignore save_lines;
%ignore term_lines;
%ignore gl_namedone;
%ignore data_as_stack;
%ignore calc_stack_alignment;
%ignore align_down_to_stack;
%ignore align_up_to_stack;
%ignore remove_spaces;
%ignore bgcolors;

%ignore set_user_defined_prefix;
%rename (set_user_defined_prefix) py_set_user_defined_prefix;

%ignore generate_disassembly;
%rename (generate_disassembly) py_generate_disassembly;

%ignore tag_remove;
%rename (tag_remove) py_tag_remove;

%ignore tag_addr;
%rename (tag_addr) py_tag_addr;

%ignore tag_skipcodes;
%rename (tag_skipcodes) py_tag_skipcodes;

%ignore tag_skipcode;
%rename (tag_skipcode) py_tag_skipcode;

%ignore tag_advance;
%rename (tag_advance) py_tag_advance;

%include "lines.hpp"

%{
//<code(py_lines)>
//------------------------------------------------------------------------
static PyObject *py_get_user_defined_prefix = NULL;
static void idaapi s_py_get_user_defined_prefix(
  ea_t ea,
  int lnnum,
  int indent,
  const char *line,
  char *buf,
  size_t bufsize)
{
  PyObject *py_ret = PyObject_CallFunction(
    py_get_user_defined_prefix, 
    PY_FMT64 "iis" PY_FMT64,
    ea, lnnum, indent, line, bufsize);

  // Error? Display it
  // No error? Copy the buffer
  if ( !PyW_ShowCbErr("py_get_user_defined_prefix") )
  {
    Py_ssize_t py_len;
    char *py_str;
    if ( PyString_AsStringAndSize(py_ret, &py_str, &py_len) != -1 )
    {
      memcpy(buf, py_str, qmin(bufsize, py_len));
      if ( py_len < bufsize )
        buf[py_len] = '\0';
    }
  }
  Py_XDECREF(py_ret);
}
//</code(py_lines)>
%}

%inline %{
//<inline(py_lines)>

//------------------------------------------------------------------------
/*
#<pydoc>
def set_user_defined_prefix(width, callback):
    """
    User-defined line-prefixes are displayed just after the autogenerated
    line prefixes. In order to use them, the plugin should call the
    following function to specify its width and contents.
    @param width: the width of the user-defined prefix
    @param callback: a get_user_defined_prefix callback to get the contents of the prefix.
        Its arguments:
          ea     - linear address
          lnnum  - line number
          indent - indent of the line contents (-1 means the default instruction)
                   indent and is used for instruction itself. see explanations for printf_line()
          line   - the line to be generated. the line usually contains color tags this argument 
                   can be examined to decide whether to generated the prefix
          bufsize- the maximum allowed size of the output buffer
        It returns a buffer of size < bufsize
    
    In order to remove the callback before unloading the plugin, specify the width = 0 or the callback = None
    """
    pass
#</pydoc>
*/
static PyObject *py_set_user_defined_prefix(size_t width, PyObject *pycb)
{
  if ( width == 0 || pycb == Py_None )
  {
    // Release old callback reference
    Py_XDECREF(py_get_user_defined_prefix);
  
    // ...and clear it
    py_get_user_defined_prefix = NULL;

    // Uninstall user defind prefix
    set_user_defined_prefix(0, NULL);
  }
  else if ( PyCallable_Check(pycb) )
  {
    // Release old callback reference
    Py_XDECREF(py_get_user_defined_prefix);

    // Copy new callback and hold a reference
    py_get_user_defined_prefix = pycb;
    Py_INCREF(py_get_user_defined_prefix);

    set_user_defined_prefix(width, s_py_get_user_defined_prefix);
  }
  else
  {
    Py_RETURN_FALSE;
  }
  Py_RETURN_TRUE;
}

//-------------------------------------------------------------------------
/*
#<pydoc>
def tag_remove(colstr):
    """
    Remove color escape sequences from a string
    @param colstr: the colored string with embedded tags
    @return: 
        None on failure
        or a new string w/o the tags
    """
    pass
#</pydoc>
*/
PyObject *py_tag_remove(const char *instr)
{
  size_t sz = strlen(instr);
  char *buf = new char[sz + 5];
  if ( buf == NULL )
    Py_RETURN_NONE;
  
  ssize_t r = tag_remove(instr, buf, sz);
  PyObject *res;
  if ( r < 0 )
  {
    Py_INCREF(Py_None);
    res = Py_None;
  }
  else
  {
    res = PyString_FromString(buf);
  }
  delete [] buf;
  return res;
}

//-------------------------------------------------------------------------
PyObject *py_tag_addr(ea_t ea)
{
  char buf[100];
  tag_addr(buf, buf + sizeof(buf), ea);
  return PyString_FromString(buf);
}

//-------------------------------------------------------------------------
int py_tag_skipcode(const char *line)
{
  return tag_skipcode(line)-line;
}

//-------------------------------------------------------------------------
int py_tag_skipcodes(const char *line)
{
  return tag_skipcodes(line)-line;
}

//-------------------------------------------------------------------------
int py_tag_advance(const char *line, int cnt)
{
  return tag_advance(line, cnt)-line;
}

//-------------------------------------------------------------------------
/*
#<pydoc>
def generate_disassembly(ea, max_lines, as_stack, notags):
    """
    Generate disassembly lines (many lines) and put them into a buffer
    
    @param ea: address to generate disassembly for
    @param max_lines: how many lines max to generate
    @param as_stack: Display undefined items as 2/4/8 bytes
    @return: 
        - None on failure
        - tuple(most_important_line_number, tuple(lines)) : Returns a tuple containing 
          the most important line number and a tuple of generated lines
    """
    pass
#</pydoc>
*/
PyObject *py_generate_disassembly(
  ea_t ea, 
  int max_lines, 
  bool as_stack, 
  bool notags)
{
  if ( max_lines <= 0 )
    Py_RETURN_NONE;

  qstring qbuf;
  char **lines = new char *[max_lines];
  int lnnum;
  int nlines = generate_disassembly(ea, lines, max_lines, &lnnum, as_stack);

  PyObject *py_tuple = PyTuple_New(nlines);
  for ( int i=0; i<nlines; i++ )
  {
    const char *s = lines[i];
    size_t line_len = strlen(s);
    if ( notags )
    {
      qbuf.resize(line_len+5);
      tag_remove(s, &qbuf[0], line_len);
      s = (const char *)&qbuf[0];
    }
    PyTuple_SetItem(py_tuple, i, PyString_FromString(s));
    qfree(lines[i]);
  }
  delete [] lines;
  PyObject *py_result = Py_BuildValue("(iO)", lnnum, py_tuple);
  Py_DECREF(py_tuple);
  return py_result;
}
//</inline(py_lines)>

%}

%pythoncode %{
#<pycode(py_lines)>

# ---------------- Color escape sequence defitions -------------------------
COLOR_ADDR_SIZE = 16 if _idaapi.BADADDR == 0xFFFFFFFFFFFFFFFFL else 8
SCOLOR_FG_MAX   = '\x28'             #  Max color number
SCOLOR_OPND1    = chr(cvar.COLOR_ADDR+1)  #  Instruction operand 1
SCOLOR_OPND2    = chr(cvar.COLOR_ADDR+2)  #  Instruction operand 2
SCOLOR_OPND3    = chr(cvar.COLOR_ADDR+3)  #  Instruction operand 3
SCOLOR_OPND4    = chr(cvar.COLOR_ADDR+4)  #  Instruction operand 4
SCOLOR_OPND5    = chr(cvar.COLOR_ADDR+5)  #  Instruction operand 5
SCOLOR_OPND6    = chr(cvar.COLOR_ADDR+6)  #  Instruction operand 6
SCOLOR_UTF8     = chr(cvar.COLOR_ADDR+10) #  Following text is UTF-8 encoded

# ---------------- Line prefix colors --------------------------------------
PALETTE_SIZE   =  (cvar.COLOR_FG_MAX+_idaapi.COLOR_BG_MAX)

def requires_color_esc(c):
    """
    Checks if the given character requires escaping
    @param c: character (string of one char)
    @return: Boolean
    """
    t = ord(c[0])
    return c >= COLOR_ON and c <= COLOR_INV

def COLSTR(str, tag):
    """
    Utility function to create a colored line
    @param str: The string
    @param tag: Color tag constant. One of SCOLOR_XXXX
    """
    return SCOLOR_ON + tag + str + SCOLOR_OFF + tag

#</pycode(py_lines)>

%}