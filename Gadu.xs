#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <libgadu.h>
#include <sys/types.h>


typedef struct gg_session *Sgg_session;
typedef struct gg_http	*Sgg_http;

MODULE = Net::Gadu		PACKAGE = Net::Gadu



SV *
gg_search(nickname,first_name,last_name,city,gender);
    char	*nickname
    char	*first_name
    char	*last_name
    char	*city
    int		gender
    PROTOTYPE: $$$$$
    INIT:
	AV	* results;
	struct gg_search_request *r;
	struct gg_http	*hr;
	struct gg_search *s;
	int i;
	results = (AV *)sv_2mortal((SV *)newAV());
    CODE:
	r = gg_search_request_mode_0(nickname, first_name, last_name, city, gender, 0, 0, 0, 0);
	hr = gg_search(r,0);
	s  = hr->data;

	for (i=0;i<s->count;i++) {
		HV *rh;
		
		rh=(HV *)sv_2mortal((SV *)newHV());
		
		hv_store(rh,"uin",3,newSVnv(s->results[i].uin),0);
		hv_store(rh,"first_name",10,newSVpv(s->results[i].first_name,0),0);
		hv_store(rh,"last_name",9,newSVpv(s->results[i].last_name,0),0);
		hv_store(rh,"nickname",8,newSVpv(s->results[i].nickname,0),0);
		hv_store(rh,"born",4,newSVnv(s->results[i].born),0);
		hv_store(rh,"gender",6,newSVnv(s->results[i].gender),0);
		hv_store(rh,"city",4,newSVpv(s->results[i].city,0),0);
		hv_store(rh,"active",6,newSVnv(s->results[i].active),0);
		
		av_push(results, newRV((SV *)rh));
		
		}
	gg_free_search(hr);		
	RETVAL = newRV((SV *)results);
    OUTPUT:
	RETVAL
		
		

int
gg_send_message(sess,msgclass,recipient,message)
    Sgg_session	sess
    int	msgclass
    uin_t	recipient
    const unsigned char	* message
    PROTOTYPE: $$$$


Sgg_session 
gg_login(uin,password,async)
    uin_t	uin
    char 	*password
    int 	async
    PROTOTYPE: $$$
    INIT:
	struct gg_login_params p;
    CODE:
	memset(&p, 0, sizeof(p));
	p.uin = uin;
	p.password = password;
	p.async = async;
	p.status = 0x0002;
	RETVAL = gg_login(&p);
	ST(0) = sv_newmortal();
	sv_setref_pv(ST(0), "Sgg_session", (void*)RETVAL);



int
gg_change_status(sess,status)
    Sgg_session	sess
    int status



void
gg_logoff(sess)
    Sgg_session	sess
    


void
gg_free_session(sess)
    Sgg_session sess
