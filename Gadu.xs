#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <libgadu.h>
#include <sys/types.h>
#include <arpa/inet.h>


typedef struct gg_session *Sgg_session;
typedef struct gg_http	*Sgg_http;

MODULE = Net::Gadu		PACKAGE = Net::Gadu

int
gg_ping(sess)
    Sgg_session	sess


int
gg_check_event(sess)
	Sgg_session	sess;
    PREINIT:
	int	ret = 0;
    CODE:
	
	if ((sess != NULL) && 
	    (sess->status != GG_STATUS_NOT_AVAIL) && 
	    (sess->status != GG_STATUS_NOT_AVAIL_DESCR)) {
	    fd_set rd, wr, ex;
	    FD_ZERO(&rd);
	    FD_ZERO(&wr);
	    FD_ZERO(&ex);

    	    if ((sess->check & GG_CHECK_READ))
			FD_SET(sess->fd, &rd);

	    if ((sess->check & GG_CHECK_WRITE))
			FD_SET(sess->fd, &wr);

	    FD_SET(sess->fd, &ex);

	    if (select(sess->fd + 1, &rd, &wr, &ex, NULL) == -1)
			ret = 0;

	    if (FD_ISSET(sess->fd, &ex))
			ret = 0;


	    if (FD_ISSET(sess->fd, &rd) || FD_ISSET(sess->fd, &wr))
		    ret = 1;
	} else 
	    ret = 0;

	RETVAL = ret;
    OUTPUT:
	RETVAL


SV *
gg_get_event(sess)
	Sgg_session	sess;
    PROTOTYPE: $
    PREINIT:
	struct gg_event *event;
	HV	* results;
    INIT:
	results = (HV *)sv_2mortal((SV *)newHV());
    CODE:

	if ((sess != NULL) && 
	    (sess->status != GG_STATUS_NOT_AVAIL) &&
	    (sess->status != GG_STATUS_NOT_AVAIL_DESCR) && 
	    (event = gg_watch_fd(sess))) {
    	    hv_store(results,"type",4,newSVnv(event->type),0);
	    switch (event->type) {
		case GG_EVENT_MSG:
		    hv_store(results,"msgclass",8,newSVnv(event->event.msg.msgclass),0);
		    hv_store(results,"sender",6,newSVnv(event->event.msg.sender),0);
		    hv_store(results,"message",7,newSVpv(event->event.msg.message,0),0);
		    break;
		case GG_EVENT_ACK:
		    hv_store(results,"recipient",9,newSVnv(event->event.ack.recipient),0);
		    hv_store(results,"status",6,newSVnv(event->event.ack.status),0);
		    hv_store(results,"seq",3,newSVnv(event->event.ack.seq),0);
		    break;
		case GG_EVENT_STATUS:
		    hv_store(results,"uin",3,newSVnv(event->event.status.uin),0);
		    hv_store(results,"status",6,newSVnv(event->event.status.status),0);
		    hv_store(results,"descr",5,newSVpv(event->event.status.descr,0),0);
		    break;
	    }
	    gg_free_event(event);
	    }
	    RETVAL = newRV((SV *)results);
    OUTPUT:
	RETVAL
    

SV *
gg_search(nickname,first_name,last_name,city,gender,active)
    char	*nickname
    char	*first_name
    char	*last_name
    char	*city
    int		gender
    int		active
    PROTOTYPE: $$$$$$
    INIT:
	AV	* results;
	struct gg_search_request *r;
	struct gg_http	*hr;
	struct gg_search *s;
	int i;
	results = (AV *)sv_2mortal((SV *)newAV());
    CODE:
	r = gg_search_request_mode_0(nickname, first_name, last_name, city, gender, 0, 0, active, 0);
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

SV *
gg_search_uin(uin,active)
    int		uin
    int		active
    PROTOTYPE: $$
    INIT:
	AV	* results;
	struct gg_search_request *r;
	struct gg_http	*hr;
	struct gg_search *s;
	int i;
	results = (AV *)sv_2mortal((SV *)newAV());
    CODE:
	r = gg_search_request_mode_3(uin,active,0);
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
gg_login(uin,password,async,server_addr)
    uin_t	uin
    char 	*password
    int 	async
    char	*server_addr
    PROTOTYPE: $$$$$
    INIT:
	struct gg_login_params p;
    CODE:
	memset(&p, 0, sizeof(p));
	p.uin = uin;
	p.password = password;
	p.async = async;
	p.status = 0x0002;
	p.server_addr = inet_addr(server_addr);
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
