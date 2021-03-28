from abc import ABC, abstractmethod, abstractproperty
from typing import Optional

import numpy as np
import plotly.graph_objects as go
from scipy import stats

from bayesian_ab.plots import fig_1d, histogram


class Distribution(ABC):
    @abstractproperty
    def mean(self):
        ...

    @abstractproperty
    def std(self):
        ...

    @abstractmethod
    def pdf(self, x):
        ...

    @abstractmethod
    def cdf(self, x):
        ...

    @abstractmethod
    def rvs(self, size: int):
        ...


class StatsMixin(Distribution):
    @property
    def mean(self) -> float:
        return float(self.d.mean())

    @property
    def std(self) -> float:
        return float(self.d.std())

    def pdf(self, x: float) -> float:
        return self.d.pdf(x)

    def cdf(self, x: float) -> float:
        return self.d.cdf(x)

    def rvs(self, size: int) -> np.ndarray:
        return self.d.rvs(size)

    def get_fig(self, x_min: float, x_max: float, N=1000, title=None) -> go.Figure:
        xs = np.linspace(x_min, x_max, N)
        ps = self.pdf(xs)
        t = self.__class__.__name__ if title is None else title
        return fig_1d(xs, ps, title=t)

    def histogram(
        self,
        n=10000,
        x_min: Optional[float] = None,
        x_max: Optional[float] = None,
        size: Optional[float] = None,
    ) -> go.Figure:
        xs = self.rvs(n)
        title = f"Sample of {self.__class__.__name__}"
        return histogram(xs, title=title, x_min=x_min, x_max=x_max, size=size, probability=True)


class StudentT(StatsMixin):
    def __init__(self, nu: float, mu: float, lam: float):
        """Studentのt分布

        https://en.wikipedia.org/wiki/Student%27s_t-distribution#In_terms_of_inverse_scaling_parameter_%CE%BB

        Args:
            nu (float): ν
            mu (float): μ
            lam (float): λ
        """
        self.nu = nu
        self.mu = mu
        self.lam = lam
        self.d = stats.t(nu, loc=mu, scale=(1 / lam) ** 0.5)


class Normal(StatsMixin):
    def __init__(self, mu: float, sigma2: float):
        self.mu = mu
        self.sigma2 = sigma2
        self.d = stats.norm(loc=mu, scale=np.sqrt(sigma2))


class LogNormal(StatsMixin):
    def __init__(self, mu: float, sigma: float):
        self.mu = mu
        self.sigma = sigma
        self.d = stats.lognorm(s=sigma, scale=mu)


class InverseGamma(StatsMixin):
    def __init__(self, alpha: float, beta: float):
        self.alpha = alpha
        self.beta = beta
        self.d = stats.invgamma(alpha, scale=beta)


class Beta(StatsMixin):
    def __init__(self, alpha: float, beta: float):
        self.alpha = alpha
        self.beta = beta
        self.d = stats.beta(a=alpha, b=beta)


class NormalInverseGamma(Distribution):
    def __init__(self, mu, lam, alpha, beta):
        self.mu = mu
        self.lam = lam
        self.alpha = alpha
        self.beta = beta
        self.px = StudentT(nu=2 * self.alpha, mu=self.mu, lam=self.beta / self.alpha * self.lam)

    @property
    def mean(self) -> tuple[np.float64, np.float64]:
        x = self.mu
        if self.alpha <= 1:
            return x, np.nan
        return x, self.beta / (self.alpha - 1)

    @property
    def std(self) -> tuple[np.float64, np.float64]:
        if self.alpha <= 1:
            return np.nan, np.nan
        x = (self.beta / ((self.alpha - 1) * self.lam)) ** 0.5
        if self.alpha <= 2:
            return x, np.nan
        return x, self.beta ** 2 / ((self.alpha - 1) ** 2 * (self.alpha - 2))

    def pdf(self, x: float, s2: float) -> float:
        px = stats.norm.pdf(x, loc=self.mu, scale=np.sqrt(s2 / self.lam))
        ps2 = stats.invgamma.pdf(s2, a=self.alpha, scale=self.beta)
        return float(px * ps2)

    def cdf(self, *args, **kwargs):
        raise NotImplementedError

    def rvs(self, size: int) -> np.ndarray:
        @np.vectorize
        def normal_sampling(s2):
            return stats.norm.rvs(size=1, loc=self.mu, scale=np.sqrt(s2 / self.lam))

        s2s = stats.invgamma.rvs(size=size, a=self.alpha, scale=self.beta)
        xs = normal_sampling(s2s)
        return np.stack([xs, s2s]).T

    def get_fig_x(self, x_min: float, x_max: float, N=1000) -> go.Figure:
        xs = np.linspace(x_min, x_max, N)
        ps = self.px.pdf(xs)
        return fig_1d(xs, ps, title=self.__class__.__name__)

    def histogram_x(
        self,
        n=10000,
        x_min: Optional[float] = None,
        x_max: Optional[float] = None,
        size: Optional[float] = None,
    ) -> go.Figure:
        xs = self.px.rvs(n)
        title = f"Sample of {self.__class__.__name__} marginal x"
        return histogram(xs, title=title, x_min=x_min, x_max=x_max, size=size, probability=True)
