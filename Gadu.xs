#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <libgadu.h>
#include <sys/types.h>

typedef struct gg_session *Sgg_session;

MODULE = Net::Gadu		PACKAGE = Net::Gadu


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
