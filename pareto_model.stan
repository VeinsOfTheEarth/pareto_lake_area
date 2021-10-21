data {
  int<lower=0> N;
  real x[N];
}
parameters {
  real<lower=0> alpha;
  real<lower=0> theta;
}
model {
  real lpa[N];

  theta ~ gamma(1, 3);
  alpha ~ gamma(1, 3);

  for (i in 1:N) {
    lpa[i] = pareto_lpdf(x[i] | theta, alpha);
  }

  target += sum(lpa);
}