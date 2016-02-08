
# -- ------------------------------------------------------------------------------ -- #
# -- Funciones de Google Finance API ---------------------------------------------- -- #
# -- Desarrollador Inicial: IF Francisco ME --------------------------------------- -- #
# -- Licencia: MIT ---------------------------------------------------------------- -- #
# -- ------------------------------------------------------------------------------ -- #


class CLA:
    def __init__(self,mean,covar,lB,uB):
        # Initialize the class
        if (mean==np.ones(mean.shape)*mean.mean()).all():mean[-1,0]+=1e-5
        self.mean=mean
        self.covar=covar
        self.lB=lB
        self.uB=uB
        self.w=[] # solution
        self.l=[] # lambdas
        self.g=[] # gammas
        self.f=[] # free weights