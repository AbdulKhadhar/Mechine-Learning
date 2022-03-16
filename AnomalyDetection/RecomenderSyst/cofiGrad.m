function [X,Theta,movieBias,userBias] = cofiGrad(R,nf,tol,lambda)
% Initialize coefficient matrices
[users,movies,ratings] = find(R);
nu = length(unique(users));
nm = length(unique(movies));
X = randn(nu,nf);
Theta = randn(nf,nm);
movieBias = zeros(1,nm);
userBias = zeros(nu,1);
globalMean = mean(ratings);
% Initialize gradient descent parameters
err = tol;
alpha = 0.02;
maxit = 200;
it = 0;
while (err >= tol) && (it < maxit)
    it = it+1;
    % Display progress
    if (round(it/20)-it/20 == 0)
        fprintf('Iteration: %d | Mean absolute error: %g | Max absolute error: %g\n',it,err,max(abs(E)));
    end
    E = [];
    for i = randperm(nu)
        [~,J] = find(R(i,:));
        r = full(R(i,J));
        Err = r-(X(i,:)*Theta(:,J)+userBias(i)+movieBias(J)+globalMean);
        E = [E Err];
        dX = Err*Theta(:,J)'-lambda*X(i,:);
        dTheta = X(i,:)'*Err-lambda*Theta(:,J);
        dmovieBias = Err;
        duserBias = sum(Err);
        % adjust alphas for numerical stability
        alphax = alpha/max(abs(dX(:)));
        alphat = alpha/max(abs(dTheta(:)));
        alphamb = alpha/max(abs(dmovieBias(:)));
        alphaub = alpha/max(abs(duserBias(:)));
        % Update coefficients
        X(i,:) = X(i,:)+alphax*dX;
        Theta(:,J) = Theta(:,J)+alphat*dTheta;
        movieBias(J) = movieBias(J)+alphamb*dmovieBias;
        userBias(i) = userBias(i)+alphaub*duserBias;
    end
    err = mean(abs(E));
end
fprintf('Final Iteration: %d | Final mean absolute error: %g | Final max absolute error: %g',it,err,max(abs(E)));
end
