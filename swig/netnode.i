// Ignore kernel only & unexported symbols
%ignore netlink;

%ignore RootNode;
%ignore for_all_supvals;
%ignore netErrorHandler;
%ignore netnode_key_count;

%ignore netnode_check;
%ignore netnode_kill;
%ignore netnode_start;
%ignore netnode_end;
%ignore netnode_next;
%ignore netnode_prev;
%ignore netnode_name;
%ignore netnode_rename;
%ignore netnode_valobj;
%ignore netnode_valstr;
%ignore netnode_set;
%ignore netnode_delvalue;
%ignore netnode_altval;
%ignore netnode_charval;
%ignore netnode_altval_idx8;
%ignore netnode_charval_idx8;
%ignore netnode_supval;
%ignore netnode_supstr;
%ignore netnode_supset;
%ignore netnode_supdel;
%ignore netnode_sup1st;
%ignore netnode_supnxt;
%ignore netnode_suplast;
%ignore netnode_supprev;
%ignore netnode_supval_idx8;
%ignore netnode_supstr_idx8;
%ignore netnode_supset_idx8;
%ignore netnode_supdel_idx8;
%ignore netnode_sup1st_idx8;
%ignore netnode_supnxt_idx8;
%ignore netnode_suplast_idx8;
%ignore netnode_supprev_idx8;
%ignore netnode_supdel_all;
%ignore netnode_supdel_range;
%ignore netnode_supdel_range_idx8;
%ignore netnode_hashval;
%ignore netnode_hashstr;
%ignore netnode_hashval_long;
%ignore netnode_hashset;
%ignore netnode_hashdel;
%ignore netnode_hash1st;
%ignore netnode_hashnxt;
%ignore netnode_hashlast;
%ignore netnode_hashprev;
%ignore netnode_blobsize;
%ignore netnode_getblob;
%ignore netnode_setblob;
%ignore netnode_delblob;
%ignore netnode_inited;
%ignore netnode_copy;
%ignore netnode_altshift;
%ignore netnode_charshift;
%ignore netnode_supshift;
%ignore netnode_altadjust;
%ignore netnode_exist;

%ignore netnode::truncate_zero_pages;
%ignore netnode::append_zero_pages;
%ignore netnode::createbase;
%ignore netnode::checkbase;
%ignore netnode::set_close_flag;
%ignore netnode::reserve_nodes;
%ignore netnode::validate;
%ignore netnode::upgrade;
%ignore netnode::compress;
%ignore netnode::inited;
%ignore netnode::init;
%ignore netnode::flush;
%ignore netnode::term;
%ignore netnode::killbase;
%ignore netnode::getdrive;
%ignore netnode::getgraph;
%ignore netnode::registerbase;
%ignore netnode::setbase;

%ignore netnode::altadjust;

%ignore netnode::operator nodeidx_t;

// Renaming one version of hashset() otherwise SWIG will not be able to activate the other one
%rename (hashset_idx) netnode::hashset(const char *idx, nodeidx_t value, char tag=htag);

%include "netnode.hpp"

%extend netnode 
{
    nodeidx_t index()
    {
      return self->operator nodeidx_t();
    }
}