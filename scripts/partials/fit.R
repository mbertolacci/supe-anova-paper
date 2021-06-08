library(Matrix)
library(WoodburyMatrix)

softplus <- function(x) {
  ifelse(x > 30, x, log1p(exp(x)))
}

inv_softplus <- function(x) {
  ifelse(x > 30, x, log(exp(x) - 1))
}

nlm_best_of <- function(fn, k, best_of = 5, max_attempts = 100, ...) {
  good_attempts <- 0
  best_result <- list(minimum = Inf)
  for (attempt in seq_len(max_attempts)) {
    result <- tryCatch({
      nlm(fn, rnorm(k), ...)
    }, error = function(e) {
      print(e)
      NULL
    })

    if (is.null(result) || result$code %in% (3 : 5)) next

    good_attempts <- good_attempts + 1
    if (result$minimum < best_result$minimum) {
      best_result <- result
    }
    if (good_attempts == best_of) break
  }
  if (attempt == max_attempts) stop('Max attempts exceeded')

  best_result
}

fit_model <- function(
  observations,
  fe_factor,
  re_factor,
  variance_factor,
  scale_factor = sd(observations),
  shape_tau_model = 13.2148,
  ...
) {
  stopifnot(is.factor(fe_factor))
  stopifnot(is.factor(re_factor))
  stopifnot(is.factor(variance_factor))

  y <- observations / scale_factor
  fe_factor <- droplevels(fe_factor)
  re_factor <- droplevels(re_factor)
  variance_factor <- droplevels(variance_factor)

  X <- sparse.model.matrix(~ fe_factor - 1)
  Z <- sparse.model.matrix(~ re_factor - 1)

  restricted_log_likelihood <- function(
    tau_re,
    tau_model,
    scale_tau_model
  ) {
    Sigma_f <- WoodburyMatrix(
      A = Diagonal(x = tau_model[variance_factor]),
      B = Diagonal(x = rep(tau_re, ncol(Z))),
      X = Z
    )
    Q_mu <- crossprod(X, solve(Sigma_f, X))
    mu_hat <- solve(Q_mu, crossprod(X, solve(Sigma_f, y)))
    e_hat <- y - as.vector(X %*% mu_hat)

    -0.5 * (
      determinant(Q_mu, logarithm = TRUE)$modulus
      + determinant(Sigma_f, logarithm = TRUE)$modulus
      + as.vector(crossprod(e_hat, solve(Sigma_f, e_hat)))
    ) + sum(dgamma(
      tau_model,
      shape = shape_tau_model,
      scale = scale_tau_model,
      log = TRUE
    ))
  }

  fit <- nlm_best_of(
    function(theta) {
      -restricted_log_likelihood(
        softplus(theta[1]),
        softplus(theta[2 : (1 + nlevels(variance_factor))]),
        softplus(theta[2 + nlevels(variance_factor)])
      )
    },
    nlevels(variance_factor) + 2,
    ...
  )

  tau_re_hat <- softplus(fit$estimate[1]) / scale_factor ^ 2
  tau_model_hat <- softplus(fit$estimate[2 : (1 + nlevels(variance_factor))]) / scale_factor ^ 2
  scale_tau_model_hat <- softplus(fit$estimate[2 + nlevels(variance_factor)]) / scale_factor ^ 2

  X_star <- cbind(X, Z)
  Q_star <- bdiag(
    Diagonal(x = rep(0, ncol(X))),
    Diagonal(x = rep(tau_re_hat, ncol(Z)))
  )
  D_f <- Diagonal(x = 1 / tau_model_hat[variance_factor])
  Q_mu_alpha <- crossprod(X_star, solve(D_f, X_star)) + Q_star
  mu_alpha_hat <- solve(Q_mu_alpha, crossprod(X_star, solve(D_f, observations)))

  X_star_1 <- t(X_star[1, ])
  prediction_variance <- as.vector(
    X_star_1 %*% solve(Q_mu_alpha, t(X_star_1))
  )

  list(
    tau_re = tau_re_hat,
    tau_model = tau_model_hat,
    scale_tau_model = scale_tau_model_hat,
    mu = head(mu_alpha_hat, ncol(X)),
    alpha = tail(mu_alpha_hat, ncol(Z)),
    Q_mu_alpha = Q_mu_alpha,
    prediction = as.vector(X_star %*% mu_alpha_hat),
    prediction_variance = prediction_variance
  )
}
